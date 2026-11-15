---
author: cjd
title: "Behind the Curtains: How My Multi-Node K3s Cluster is Setup"
date: "2026-11-15T15:30:00+11:00"
tags:
  - general
  - homelab
  - kubernetes
url: /blog/2026/11/homelab-k3s-cluster-setup
showToc: false
---

The tagline for my blog is *"Always keep a spare for redundancy,"* and nowhere is that philosophy more thoroughly tested—and relied upon—than in my homelab. 

Earlier this year, I wrote about [how I automate volume backups using Kyverno sidecars](/blog/2026/05/volsync-kyverno) to protect my Longhorn persistent data. But storage backups are only one gear in the clockwork. Over the past couple of years, my homelab infrastructure has evolved from a collection of ad-hoc Docker containers and bespoke scripts into a fully declarative, multi-node **K3s** cluster managed strictly through GitOps.

It runs everything in our household and beyond: Home Assistant, Frigate NVR with hardware object detection, distributed ESPHome compilers, Jellyfin media streaming, dedicated automation and Christmas light services for my local church (101 Church Narara AKA C3 Narara) using Falcon Player (FPP), self-hosted git repos, local LLMs with Ollama, and all the plumbing in between.

Here is a look behind the scenes at how the cluster is structured, the architectural choices that keep it rock-solid, and the neat automation tricks that save me from constant maintenance headaches.

---

### The Hardware Topology & Node Fleet

Like many homelabs, my cluster didn't start with rack-mounted enterprise blade servers; it grew organically out of quiet, power-efficient small form-factor machines. Because I like having fun with naming schemes, the core nodes take their names from *The Big Bang Theory*:

| Node | Role | IP / Interface | Function & Hardware Notes |
| :--- | :--- | :--- | :--- |
| `jimbob` | Control Plane, etcd | `192.168.0.2` | The cluster workhorse: houses the ZFS storage pool (`/tank/*`), local registry cache, and NAS backup bridge. |
| `raj` | Control Plane, etcd | `192.168.0.4` | High-availability control-plane peer and host for Frigate NVR (the only workload pinned here, thanks to a physical Google Coral Edge TPU). |
| `howard` | Control Plane, etcd | `192.168.0.6` | High-availability control-plane peer and general workload runner. |
| `leonard` | Worker | `192.168.0.5` | Dedicated worker for general application workloads and heavy compute. |
| `fanless` | Remote Worker | `10.8.0.8` (`wg0`) | Low-power remote node connected over WireGuard (`site=remote:NoSchedule`). |
| `gcp-k8s-node` | Remote Worker | `10.8.0.7` (`wg0`) | Cloud compute node connected via WireGuard for off-site burst capacity. |

One key design goal was flexibility: workloads like Home Assistant, ESPHome builders, databases, and media runners aren't hardcoded to specific machines. They float freely across the cluster and reschedule onto any healthy node. The only notable exception is Frigate on `raj`, strictly because of the physical Coral Edge TPU plugged into that host.

To make provisioning reproducible, I wrote an onboarding script (`add_node.sh`) that asks a few quick questions (LAN vs. WireGuard, control-plane vs. worker, Coral TPU or NVIDIA GPU) and configures the host automatically. It installs prerequisite kernel modules and packages (`open-iscsi`, `cryptsetup`, `nfs-common` for Longhorn), writes out `/etc/rancher/k3s/registries.yaml` to point to the local image cache, sets up Coral Edge TPU drivers (`gasket-dkms`, `libedgetpu1-std`) if needed, and joins the cluster.

---

### High Availability Without Enterprise Gear: kube-vip

Running a multi-master Kubernetes cluster usually presents a chicken-and-egg problem: worker nodes and `kubectl` need a single reliable API endpoint, but standard Kubernetes doesn't provide a virtual IP out of the box without external hardware or cloud load balancers.

Enter **[kube-vip](https://kube-vip.io/)**. 

By running kube-vip on the control-plane nodes (`jimbob`, `raj`, `howard`), they share a Virtual IP (`192.168.0.254:6443`) using ARP leader election. When all three masters run embedded etcd, any single master can be rebooted or taken down for maintenance without dropping `kubectl` access or disrupting cluster reconciliation:

```
                  ┌───────────────────────────────┐
                  │ Virtual API IP: 192.168.0.254 │
                  └───────────────┬───────────────┘
                                  │ (ARP Failover via kube-vip)
            ┌─────────────────────┼─────────────────────┐
            ▼                     ▼                     ▼
      ┌───────────┐         ┌───────────┐         ┌───────────┐
      │  jimbob   │◄───────►│    raj    │◄───────►│  howard   │
      │ (K3s/etcd)│         │ (K3s/etcd)│         │ (K3s/etcd)│
      └───────────┘         └───────────┘         └───────────┘
```

The initial master initializes etcd with `--cluster-init`, and subsequent masters join via `--server https://192.168.0.254:6443`. Clean, robust, and completely self-contained.

---

### GitOps Engine: Forgejo, ArgoCD & Renovate

I don't run `kubectl apply` manually for regular applications. Everything that runs on the cluster is defined in a Git repository hosted on an internal **Forgejo** instance, and reconciled by **ArgoCD**.

The repository is structured cleanly by category:

- `ha/`: Home automation stack (Home Assistant Core, distributed ESPHome builders, Mosquitto MQTT, Frigate NVR, Zigbee, Matter).
- `media/`: Streaming and cataloging (Jellyfin, Immich, Navidrome, Komga, Audiobookshelf, Grimmory).
- `bandwidth/`: Download management and media indexing (Sonarr, Radarr, Prowlarr, qBittorrent, Seerr).
- `home/`: Productivity tools (Forgejo, Bitwarden, Paperless-ngx, Ollama, Open-WebUI, Homepage dashboard).
- `c3/`: Services supporting my local church (101 Church Narara AKA C3 Narara), including Falcon Player / FPP for event and production lighting automation, a dedicated C3 Home Assistant instance, MQTT, and Caddy.
- `infra/`: Cluster monitoring (Grafana, Loki, Promtail, Telegraf, Scrutiny), Dex SSO, VolSync NAS bridges.
- `helm/`: Cluster Helm charts (Traefik, Longhorn, Kyverno, MetalLB, cert-manager, CrowdSec, Headlamp).

To keep this from rotting over time, **Renovate** monitors the repository and submits automated pull requests whenever container images or Helm chart versions are updated upstream.

---

### Networking, Ingress & Security

Networking in a homelab requires balancing internal security with smooth access across IoT subnets, local PCs, and external mobile devices.

#### MetalLB & Shared LoadBalancer IPs
For bare-metal IP allocation, I use **MetalLB** with a pool of local IPs (`192.168.0.20` – `192.168.0.39`). One killer feature of MetalLB that doesn't get enough love is the `metallb.io/allow-shared-ip` annotation. 

For instance, Home Assistant needs several different ports open (web UI, HomeKit, native integrations), but I want them all bound to a single familiar LAN address (`192.168.0.20`). By assigning them to a shared IP key (`homeassist-shared-ip`), MetalLB lets disparate services share that single IP without port collision.

#### Traefik, cert-manager, CrowdSec & Dex SSO
All external and HTTP-based internal traffic flows through **Traefik** on port 443:
- **TLS Automation**: `cert-manager` automatically manages our wildcard TLS certificate (`home-adebenham-com-tls`) via DNS-01 challenges.
- **Intrusion Prevention**: Traefik runs with a **CrowdSec** middleware bouncer to instantly drop malicious or abusive requests.
- **Single Sign-On (SSO)**: Rather than dealing with fragmented auth credentials on every web UI, private internal services are protected with the `traefik-sso` forward-auth middleware backed by **Dex OIDC**.

---

### Storage: The Two-Tiered Approach

Storage in a homelab is rarely one-size-fits-all. Database-driven applications like Forgejo, Home Assistant, and Paperless demand fast random I/O and snapshots; media libraries, ROMs, and download directories need tens of terabytes of bulk capacity.

I split storage cleanly into two tiers:

```
┌─────────────────────────────────────────────────────────────┐
│                       Storage Strategy                      │
├──────────────────────────────┬──────────────────────────────┤
│      Fast / Stateful Tier    │         Bulk Data Tier       │
│      (Longhorn Block NVMe)   │      (Static ZFS NFS Exports)│
├──────────────────────────────┼──────────────────────────────┤
│ • App databases (SQLite, etc)│ • Movies (/tank/Movies)      │
│ • Home Assistant state       │ • TV Shows (/tank/Television)│
│ • Immich database            │ • Music (/tank/Music)        │
│ • Forgejo repositories       │ • Downloads (/tank/Downloads)│
│ • VolSync backup sidecars    │ • Games & ROMs (/tank/Games) │
└──────────────────────────────┴──────────────────────────────┘
```

1. **Fast Tier (Longhorn)**: Distributed NVMe block storage running across the local nodes. It provides volume replication and snapshot capabilities.
2. **Bulk Data Tier (ZFS over NFS)**: `jimbob` hosts a large ZFS pool (`/tank/*`). These datasets are statically exported over NFS via declarative PVs/PVCs (`nfs-movies-pvc`, `nfs-television-pvc`, `nfs-music-pvc`, `nfs-games-pvc`, `nfs-downloads-pvc`). 

This keeps write-heavy app data running at full NVMe speeds without filling up expensive SSDs with raw 4K video files or music libraries.

---

### Policy Automation: Kyverno Does the Heavy Lifting

When running dozens of services across multiple namespaces, boilerplate YAML becomes a huge drag. To solve this, **Kyverno** acts as the cluster's policy engine and automator:

#### 1. VolSync Backup & Restore Sidecars
As I detailed in my [earlier post](/blog/2026/05/volsync-kyverno), Kyverno watches for the annotation `volsync.cjd.io/sync: "true"` on any Pod. It dynamically injects:
- A `preload-data` initContainer that automatically restores volume data from the NAS if an empty volume starts up.
- A native `backupvolumes` sidecar (`restartPolicy: Always`) that continuously rsyncs data changes back to the NAS over SSH, including a final sync on container termination.

#### 2. Cross-Namespace Secret & Certificate Synchronization
Normally in Kubernetes, secrets are namespace-scoped. If you have an API key or wildcard TLS certificate, you find yourself copying it into five different namespaces. 

Kyverno solves this with `GeneratingPolicy` rules:
- Any wildcard certificate generated by cert-manager in the `default` namespace is automatically cloned into all other namespaces ([`tls-sync-policy.yml`](#)).
- Cluster secrets like DNS API tokens (`cloudflare`, `godaddy`) and `rsync-secret` in `kube-system` are synced cluster-wide automatically.

---

### Taming Docker Rate Limits: The Pull-Through Cache

If you've ever had a cluster upgrade trigger simultaneous pulls of 20 container images across 5 nodes, you know what happens: either Docker Hub slaps you with a 429 Rate Limit error, or your internet connection crawls to a halt.

To fix this, I run a multi-registry pull-through cache on `jimbob` (`192.168.0.2`):
- **Port 5000**: Docker Hub Proxy
- **Port 5001**: GitHub Container Registry (GHCR) Proxy
- **Port 5002**: LinuxServer.io (LSCR) Proxy

Every node's `/etc/rancher/k3s/registries.yaml` configures these as upstream mirrors:

```yaml
mirrors:
  "docker.io":
    endpoint:
      - "http://192.168.0.2:5000"
  "ghcr.io":
    endpoint:
      - "http://192.168.0.2:5001"
  "lscr.io":
    endpoint:
      - "http://192.168.0.2:5002"
```

Cached images have a 7-day TTL (`REGISTRY_PROXY_TTL: "168h"`), and a Kubernetes CronJob (`ghcr-proxy-gc`) triggers every Sunday at 3:00 AM to garbage-collect unreferenced layers (`registry garbage-collect --delete-untagged=true`). Image pulls on worker nodes are near-instantaneous over Gigabit LAN.

---

### Frictionless Upgrades: System Upgrade Controller

Upgrading Kubernetes control-plane components and agent nodes manually via SSH is tedious and error-prone. 

Instead, I use Rancher's **System Upgrade Controller** (`k3s_upgrade_plan.yaml`). When I bump the target K3s version:
1. The `server-plan` runs first, updating one control-plane node at a time. It cordons and drains the node, updates the K3s binary, restarts the service, waits for etcd health to recover, and uncordons the node.
2. Once all control-plane servers are healthy on the new version, the `agent-plan` sequentially upgrades the worker nodes.

I can push a version update to Git before going to sleep and wake up to an upgraded, healthy cluster without ever opening a terminal.

---

### Wrapping Up

Building a homelab cluster this way takes some initial effort upfront, but the payoff in day-to-day operations is massive:

1. **Disaster Recovery is Trivial**: If a node dies or an SSD fails, Longhorn rebuilds the replicas or Kyverno/VolSync restores the data into a fresh volume automatically.
2. **Maintenance is Stress-Free**: kube-vip handles API failover, System Upgrade Controller handles OS/K3s updates, and pull-through caching prevents download bottlenecks.
3. **Everything is in Git**: If I need to tear down a service, reconfigure Traefik routing, or add an ingress rule, it's a one-line Git commit that ArgoCD reconciles in seconds.

It strikes that sweet spot of high reliability and minimal ongoing babysitting—which means more time to tinker with church and holiday lighting shows, home automation projects, and new experiments, and less time recovering dead containers.
