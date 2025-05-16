#!/bin/bash

# Apply the namespace
kubectl apply -f namespace.yaml

# Apply the ConfigMap
kubectl apply -f nginx-configmap.yaml

# Apply the Deployment
kubectl apply -f nginx-deployment.yaml

# Apply the Service
kubectl apply -f nginx-service.yaml

echo "All configurations applied."
echo "To get the service URL, you might need to port-forward or check your ingress controller."
echo "For example, to port-forward for local testing (run in a separate terminal):"
echo "kubectl port-forward svc/nginx-service -n secret-code 8080:80"
echo "Then access http://localhost:8080"