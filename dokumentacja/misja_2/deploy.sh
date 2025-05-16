#!/bin/bash
# deploy.sh - Installs Longhorn storage solution with replication capabilities

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Starting Longhorn deployment - Misja 2 'Long Horn'"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: helm not found. Please install Helm first.${NC}"
    exit 1
fi

# Create the longhorn-system namespace
echo "Creating longhorn-system namespace..."
kubectl apply -f namespace.yaml

# Add Longhorn Helm repository
echo "Adding Longhorn Helm repository..."
helm repo add longhorn https://charts.longhorn.io
helm repo update

# Check if Longhorn is already installed
if helm list -n longhorn-system | grep -q longhorn; then
    echo "Longhorn is already installed. Upgrading the installation..."
    helm upgrade longhorn longhorn/longhorn \
      --namespace longhorn-system \
      -f longhorn-values.yaml \
      --version v1.5.2
else
    # Install the latest stable version of Longhorn
    echo "Installing Longhorn with 1 replica configuration..."
    helm install longhorn longhorn/longhorn \
      --namespace longhorn-system \
      -f longhorn-values.yaml \
      --version v1.5.2
fi

echo "Waiting for Longhorn pods to be ready..."
# First wait for the deployments to create pods
sleep 10
# Try multiple selectors as Longhorn labels may vary
if ! kubectl -n longhorn-system wait --for=condition=ready pod --selector=app=longhorn-manager --timeout=60s 2>/dev/null; then
    echo "Trying alternative selector..."
    kubectl -n longhorn-system wait --for=condition=ready pod --selector=app.kubernetes.io/name=longhorn --timeout=300s || true
fi

# Check that some pods are running in the namespace regardless of labels
echo "Verifying Longhorn component pods are running..."
RUNNING_PODS=$(kubectl get pods -n longhorn-system | grep -c "Running")
if [ "$RUNNING_PODS" -gt 0 ]; then
    echo -e "${GREEN}Longhorn pods are starting up successfully.${NC}"
else
    echo -e "${RED}Warning: No running Longhorn pods found. Installation might have issues.${NC}"
fi

# Check if the storage class was created
echo "Checking if Longhorn StorageClass was created..."

# Give more time for the Longhorn components to create the StorageClass
echo "Waiting for Longhorn StorageClass to be created (may take up to 2 minutes)..."
for i in $(seq 1 12); do
    if kubectl get storageclass | grep -q longhorn; then
        echo -e "${GREEN}Success! Longhorn StorageClass is available.${NC}"
        break
    else
        echo "StorageClass not ready yet. Waiting... ($i/12)"
        sleep 10
        if [ $i -eq 12 ]; then
            echo -e "${RED}Error: Longhorn StorageClass was not created after waiting.${NC}"
            echo "Let's check if the CSI driver is properly installed..."
            kubectl get pods -n longhorn-system | grep csi
            echo "Let's check the status of all Longhorn components..."
            kubectl get all -n longhorn-system
            echo -e "${RED}You may need to check the logs of the Longhorn manager or CSI components to debug.${NC}"
            exit 1
        fi
    fi
done

# Make Longhorn the default StorageClass
echo "Setting Longhorn as the default StorageClass..."
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Create a test PVC to validate the setup
echo "Creating a test PersistentVolumeClaim to validate the setup..."
kubectl apply -f - << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: longhorn-test-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 1Gi
EOF

# Wait for PVC to be bound
echo "Waiting for the test PVC to be bound..."
kubectl wait --for=condition=bound pvc/longhorn-test-pvc --namespace default --timeout=60s

# Check if the PVC was created successfully
if kubectl get pvc longhorn-test-pvc -n default | grep -q Bound; then
    echo -e "${GREEN}Success! Test PVC was created and bound successfully.${NC}"
    echo -e "${GREEN}Longhorn storage solution has been successfully deployed!${NC}"
else
    echo -e "${RED}Error: Test PVC was not bound. There might be an issue with the Longhorn setup.${NC}"
    exit 1
fi

echo "Cleaning up test resources..."
kubectl delete pvc longhorn-test-pvc -n default

echo -e "${GREEN}===========================================================${NC}"
echo -e "${GREEN}Mission 2 - 'Long Horn' completed successfully!${NC}"
echo -e "${GREEN}Software-defined storage with replication capability installed.${NC}"
echo -e "${GREEN}Longhorn is now your default StorageClass.${NC}"
echo -e "${GREEN}===========================================================${NC}"
