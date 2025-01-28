---
author: cjd
title: Getting metrics out of longhorn without prometheus
date: "2025-01-16T00:00:00+11:00"
tags:
  - general
  - homelab
url: /blog/2025/01/longhorn-metrics
showToc: false
---

Recently, I migrated all my homelab Kubernetes storage to Longhorn. While Longhorn provides excellent features, monitoring its performance is crucial for identifying potential issues and optimizing resource utilization.

Longhorn offers Prometheus as the recommended monitoring solution. However, since I use InfluxDB for my time-series data needs, I needed to find a way to integrate Longhorn metrics with my existing setup.

Longhorn exposes metrics on each of its `longhorn-manager` pods. However, there's no dedicated service to access these metrics directly. Furthermore, the names of these pods can change dynamically, making it impossible to create a static endpoint for InfluxDB.

To get around this, I created a small deployment that runs a basic Python script. This script performs the following tasks:

1. Discovers `longhorn-manager` Pods: It dynamically discovers the currently running `longhorn-manager` pods within the cluster.
2. Scrapes Metrics: It iterates through each `longhorn-manager` pod and fetches the metrics endpoint (`http://podname:9500/metrics`) from each.
3. Aggregates Metrics: The script combines the metrics data from all `longhorn-manager` pods into a single response.
4. Exposes Metrics: The script listens on port 9500 and serves the aggregated metrics data to any client that requests it.

For this to work there is a bit of support structure - basically I need to ensure that the pod has sufficient access to make some kubectl queries (to find the names of the longhorn-manager pods).  I also put the script itself into a ConfigMap to make it easier to update.

Once the Deployment, ServiceAccount, Role, RoleBinding and Service are deployed I can simply point InfluxDB at `http://longhorn-metrics-collector.longhorn-system:9500/metrics`


**ConfigMap - longhorn-metrics-collector-script**

```yaml
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: longhorn-metrics-collector-script
  namespace: longhorn-system
data:
  collector.py: |
    import http.server
    import socketserver
    import subprocess
    import json

    class MetricsHandler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == '/metrics':
                try:
                    pod_ips = subprocess.check_output(["kubectl", "get", "pods", "-l", "app=longhorn-manager", "-o", "jsonpath={.items[*].status.podIP}"]).decode('utf-8').split()
                    metrics = ""
                    all_metrics = []
                    for pod_ip in pod_ips:
                        try:
                            pod_metrics = subprocess.check_output(["curl", "-s", f"http://{pod_ip}:9500/metrics"]).decode('utf-8') + "\n"
                            all_metrics.extend(pod_metrics.splitlines())
                        except subprocess.CalledProcessError as e:
                            print(f"Error fetching metrics from {pod_ip}: {e}")
                    seen = set()
                    unique_metrics = []
                    for line in all_metrics:
                        if line not in seen:
                          unique_metrics.append(line)
                          seen.add(line)

                    self.send_response(200)
                    self.send_header("Content-type", "text/plain")
                    self.end_headers()
                    self.wfile.write("\n".join(unique_metrics).encode('utf-8'))
                    self.wfile.write("\n".encode('utf-8'))
                except subprocess.CalledProcessError as e:
                    self.send_error(500, "Failed to get pod IPs: " + str(e))
            else:
                self.send_error(404, "Not Found")

    if __name__ == "__main__":
        with socketserver.TCPServer(("", 9500), MetricsHandler) as httpd:
            print("Serving at http://localhost:9500")
            httpd.serve_forever()
```

**Deployment - longhorn-metrics-collector**

```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: longhorn-metrics-collector
  namespace: longhorn-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: longhorn-metrics-collector
  template:
    metadata:
      labels:
        app: longhorn-metrics-collector
    spec:
      serviceAccountName: longhorn-metrics-collector-sa
      containers:
        - name: collector
          image: python:alpine
          command: ["sh", "-c", "apk add curl kubectl && python /scripts/collector.py"]
          volumeMounts:
            - name: collector-script
              mountPath: /scripts
          ports:
            - containerPort: 9500
      volumes:
        - name: collector-script
          configMap:
            name: longhorn-metrics-collector-script
```

**Service - longhorn-metrics-collector**

```yaml
# Service
apiVersion: v1
kind: Service
metadata:
  name: longhorn-metrics-collector
  namespace: longhorn-system
spec:
  selector:
    app: longhorn-metrics-collector
  ports:
    - protocol: TCP
      port: 9500
      targetPort: 9500
```

**ServiceAccount - longhorn-metrics-collector-sa**

```yaml
# ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: longhorn-metrics-collector-sa
  namespace: longhorn-system
```

**Role - longhorn-metrics-collector-role**

```yaml
# Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: longhorn-metrics-collector-role
  namespace: longhorn-system
rules:
  - apiGroups: [""] # for core resources
    resources: ["pods"]
    verbs: ["get", "list"]
```

**RoleBinding - longhorn-metrics-collector-role-binding**

```yaml
# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: longhorn-metrics-collector-role-binding
  namespace: longhorn-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: longhorn-metrics-collector-role
subjects:
  - kind: ServiceAccount
    name: longhorn-metrics-collector-sa
    namespace: longhorn-system
```
