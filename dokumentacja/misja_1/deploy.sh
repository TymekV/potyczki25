#!/bin/bash

# Create project on the "potyczki" cluster
kubectl config use-context potyczki
kubectl create namespace szk-server

# Apply all configuration files
kubectl apply -f namespace.yaml
kubectl apply -f nginx-configmap.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml

# Check if the ingress controller is available
if kubectl get namespace ingress-nginx &>/dev/null; then
  # Apply the ingress if the controller is available
  kubectl apply -f nginx-ingress.yaml
  echo "Ingress controller detected, applied ingress configuration."
else
  echo "Ingress controller not detected. Will use NodePort for external access."
  # We'll continue without ingress and just use NodePort
fi

# Verify the deployment
echo "Checking namespace status:"
kubectl get namespace ogloszenia-krytyczne

echo "Checking deployment status:"
kubectl -n ogloszenia-krytyczne get deployments

echo "Checking pod status:"
kubectl -n ogloszenia-krytyczne get pods

echo "Checking service status:"
kubectl -n ogloszenia-krytyczne get services

# Display access URLs
echo "Deployment complete. The web server is accessible at:"
echo "1. Within the cluster: szk-nginx-service.ogloszenia-krytyczne.svc.cluster.local"

# If we have a NodePort service, show the NodePort URL
NODE_PORT=$(kubectl -n ogloszenia-krytyczne get service szk-nginx-service -o jsonpath='{.spec.ports[0].nodePort}')
if [ ! -z "$NODE_PORT" ]; then
  echo "2. Via NodePort: http://$EXTERNAL_IP:$NODE_PORT"
  echo "3. Via nip.io domain: http://ogloszenia-krytyczne.$EXTERNAL_IP.nip.io:$NODE_PORT"
fi

# If we applied ingress, show the Ingress URL
if kubectl -n ogloszenia-krytyczne get ingress szk-nginx-ingress &>/dev/null; then
  echo "4. Via Ingress: http://ogloszenia-krytyczne.$EXTERNAL_IP.nip.io"
fi

echo ""
echo "You can now access the web server using the above URLs from anywhere on the internet."
