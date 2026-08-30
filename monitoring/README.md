# Monitoring and logging

The cluster and application metrics are collected by Yandex Monitoring or
Managed Service for Prometheus. The application exposes health and metrics on
the management port `9090`:

- `http_server_requests_seconds_count` and `http_server_requests_seconds_sum`
  show request volume and latency;
- `http_server_requests_seconds_count{status=~"5.."}` shows server errors;
- `jvm_memory_used_bytes` and `process_cpu_usage` show application pressure;
- `kube_pod_container_status_restarts_total` shows unstable pods.

Pod logs are sent to Yandex Cloud Logging with a retention period configured
for the project folder. Filter by the Kubernetes namespace and pod labels:

```text
resource.labels.namespace_name="bulletin-board"
labels.app="bulletin-board"
```

The dashboard definition in `dashboard.json` contains the panels for request
rate, p95 latency, 5xx responses, pod restarts, CPU, and memory. The alert
rules in `alerts.yml` cover unavailable pods, high error rate, and high p95
latency. Replace the folder, cloud, and notification-channel identifiers with
the values of the target Yandex Cloud account before applying them.

Recommended verification after deployment:

```bash
kubectl -n bulletin-board get pods
kubectl -n bulletin-board logs deploy/bulletin-board --tail=100
kubectl -n bulletin-board port-forward svc/bulletin-board 9090:9090
curl http://localhost:9090/actuator/prometheus
```
