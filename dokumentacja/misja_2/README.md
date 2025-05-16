# Misja 2 - "Long Horn"

## Software-Defined Storage Solution for Kubernetes

This directory contains configuration files for deploying Longhorn, a lightweight and reliable distributed block storage system for Kubernetes with replication capabilities.

## Files:

- `namespace.yaml`: Creates the longhorn-system namespace
- `longhorn-values.yaml`: Configuration values for Longhorn deployment with replica count set to 1
- `deploy.sh`: Deployment script that installs Longhorn and sets it as the default StorageClass
- `test-pod.yaml`: Example pod definition that uses a Longhorn PVC for persistent storage

## Deployment:

To deploy Longhorn:

```bash
cd /Users/tymek/Documents/Projekty/potyczki25/dokumentacja/misja_2
chmod +x deploy.sh
./deploy.sh
```

## Features Implemented:

- Software-defined storage with replication capabilities
- Configured with 1 replica (meets the requirement while working with a single-node cluster)
- Set as the default StorageClass for the cluster
- Support for persistent volumes through the standard Kubernetes API

## Verification:

After running the deployment script, you can verify that Longhorn is working correctly by:

1. Checking the Longhorn StorageClass: `kubectl get storageclass`
2. Creating a test PVC: `kubectl apply -f test-pod.yaml`
3. Verifying the pod is running and able to write to the persistent volume

## Additional Information:

Longhorn provides a web UI that can be accessed by port-forwarding to the longhorn-frontend service:

```bash
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8000:80
```

Then visit http://localhost:8000 in your web browser.
