---
author: cjd
title: Automating storage backups with Kyverno sidecars
date: "2026-05-06T10:00:00+10:00"
tags:
  - general
  - homelab
  - kubernetes
url: /blog/2026/05/volsync-kyverno
showToc: false
---

In my homelab, I've been using Longhorn as my primary Kubernetes storage solution. It's fantastic for high-availability block storage, but I still wanted a way to keep my data synchronized with my central NAS for long-term backups and to make it easier to recover from total cluster failures.

Initially, I was manually adding a pair of `initContainers` as sidecars to every single service YAML. This worked, but it was a maintenance nightmare—I had nearly 1,500 lines of redundant boilerplate across my repository.

### The Volsync Strategy

My backup strategy relies on a custom docker image I call `volsync`. It's a small image that uses `rsync` over SSH to move data between the cluster's Longhorn volumes and my NAS. 

The source for this docker image is available on [GitHub](https://github.com/cjd/dockerfiles/tree/main/k8s-volsync), and the images can be found at `ghcr.io/cjd/k8s-volsync` (or `debenham/k8s-volsync`).

The workflow consists of two parts using this same image:

1.  **Preload (`preload-data`)**: An `initContainer` that runs before the application starts. It checks if there is anything already in the volume and if it is empty it pulls the latest data from the NAS to the Longhorn volume.  This way if I delete the volume it will be rebuilt from the backup.
2.  **Sidecar (`backupvolumes`)**: A long-running container that remains active alongside the application. It periodically pushes changes from the volume back to the NAS. It also is setup so that when the container is killed it does once last sync to the NAS so I can be sure my backup is up to date.

To make this seamless, the sidecar uses the "Native Sidecar" pattern (available in K8s 1.29+), where an `initContainer` is configured with `restartPolicy: Always`. This ensures the backupvolumes container starts before the application but continues running indefinitely.

The combination of these two initContainers means that I can feel safe deleting a pod and it's volumes - knowing that I can just re-deploy at any time.  The data was backed up right before delete, and will be restored from that backup when I redeploy.

### Automating with Kyverno

Since this needed to be done on every pod where I'm using longhorn volumes I needed to have the same basic section in every deployment yaml. To get rid of the boilerplate, I used **Kyverno**, a policy engine for Kubernetes. Instead of writing the container specs in every file, I now just add a simple annotation: `volsync.cjd.io/sync: "true"`.

Kyverno watches for this annotation and automatically injects the necessary containers, volume mounts, and environment variables.

**The Kyverno ClusterPolicy**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: inject-volsync
spec:
  rules:
    - name: inject-volsync-containers
      match:
        any:
        - resources:
            kinds:
              - Pod
            annotations:
              volsync.cjd.io/sync: "true"
      mutate:
        patchStrategicMerge:
          spec:
            initContainers:
              - name: preload-data
                image: ghcr.io/cjd/k8s-volsync:2026.04.23
                volumeMounts:
                  - name: keyfiles
                    mountPath: /root/.ssh
                    readOnly: true
                  - mountPath: /k8s/{{request.namespace}}/{{request.object.metadata.labels.app}}
                    name: "{{request.object.metadata.labels.app}}"
              - name: backupvolumes
                image: ghcr.io/cjd/k8s-volsync:2026.04.23
                restartPolicy: Always
                imagePullPolicy: Always
                command: ["/volsync.sh"]
                volumeMounts:
                  - name: keyfiles
                    readOnly: true
                    mountPath: "/root/.ssh/"
                  - mountPath: /k8s/{{request.namespace}}/{{request.object.metadata.labels.app}}
                    name: "{{request.object.metadata.labels.app}}"
```

The dynamic variables like `{{request.namespace}}` ensure that data is always synced to the correct path on the NAS (e.g., `/tank/Volumes/default/jellyfin`) without me having to configure it per service.

### Making ArgoCD Happy

One side effect of using Mutating Webhooks is that ArgoCD got confused. Because the containers are added at runtime by Kyverno, they don't exist in the Git manifests. ArgoCD sees this discrepancy and stays in a "Progressing" state forever, waiting for the live state to match Git.

To fix this, I had to update my ArgoCD configuration to ignore these injected containers during its health and sync checks.

**ArgoCD Configuration Patch**

```yaml
# Add this to your argocd-cm ConfigMap
data:
  resource.customizations.ignoreResourceUpdates.apps_StatefulSet: |
    jsonPointers:
    - /spec/template/spec/initContainers
  resource.customizations.ignoreResourceUpdates.apps_Deployment: |
    jsonPointers:
    - /spec/template/spec/initContainers
```

With this in place, ArgoCD correctly ignores the `initContainers` injected by Kyverno, allowing my applications to reach a "Healthy" status while still benefiting from automated backups.

Now, setting up a new service with full NAS-backed redundancy is as simple as adding a single line to the metadata. It's much cleaner, more maintainable, and significantly harder to forget a backup!
