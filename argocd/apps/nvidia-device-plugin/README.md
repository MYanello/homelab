Need to use [time slicing](https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file#with-cuda-time-slicing).

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nvidia-device-plugin-config
  namespace: nvidia-device-plugin
data:
  config.toml: |
    version = 1
    sharing:
      timeSlicing:
        resources:
          - name: "nvidia.com/gpu"
            replicas: 10  # Number of virtual GPUs per physical GPU
```