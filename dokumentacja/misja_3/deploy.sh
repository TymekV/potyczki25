#!/bin/bash
# deploy.sh - Adds the Rancher Rodeo repository and installs a game for the President's cat

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Starting Misja 3 - 'Kot Prezesa'"
echo "Setting up entertainment for the President's cat"

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

# Create the cat-entertainment namespace
echo "Creating cat-entertainment namespace..."
kubectl apply -f namespace.yaml

# Add the Rancher Rodeo repository
echo "Adding Rancher Rodeo repository to Helm..."
helm repo add rodeo https://rancher.github.io/rodeo
helm repo update

# Check if the repository was added successfully
if helm repo list | grep -q rodeo; then
    echo -e "${GREEN}Rancher Rodeo repository added successfully.${NC}"
else
    echo -e "${RED}Error: Failed to add the Rancher Rodeo repository.${NC}"
    exit 1
fi

# List available apps from the Rodeo repository
echo "Available games in the Rancher Rodeo repository:"
helm search repo rodeo

# Install the Tetris game from the Rodeo repository
echo "Installing Tetris game for the President's cat..."
helm install cat-game rodeo/tetris \
  --namespace cat-entertainment \
  -f game-values.yaml

# Wait for the game pods to be ready
echo "Waiting for the game pods to be ready..."
sleep 10
if ! kubectl -n cat-entertainment wait --for=condition=ready pod --selector=app.kubernetes.io/name=tetris --timeout=120s 2>/dev/null; then
    echo "Trying alternative selector..."
    kubectl -n cat-entertainment wait --for=condition=ready pod --selector=app=tetris --timeout=120s || true
fi

# Check that pods are running in the namespace
echo "Verifying game pods are running..."
RUNNING_PODS=$(kubectl get pods -n cat-entertainment | grep -c "Running")
if [ "$RUNNING_PODS" -gt 0 ]; then
    echo -e "${GREEN}Game pods are running successfully.${NC}"
else
    echo -e "${RED}Warning: No running game pods found. Installation might have issues.${NC}"
fi

# Create an ingress for the game
echo "Creating ingress for the game..."
kubectl apply -f game-ingress.yaml

# Check if the ingress was created successfully
if kubectl get ingress -n cat-entertainment | grep -q cat-game-ingress; then
    echo -e "${GREEN}Game ingress created successfully.${NC}"
else
    echo -e "${RED}Warning: Game ingress was not created.${NC}"
fi

# Get the game URL
echo -e "${GREEN}===========================================================${NC}"
echo -e "${GREEN}Mission 3 - 'Kot Prezesa' completed successfully!${NC}"
echo -e "${GREEN}The President's cat can now play the game at:${NC}"
INGRESS_HOST=$(kubectl get ingress -n cat-entertainment cat-game-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -z "$INGRESS_HOST" ]; then
    INGRESS_HOST=$(kubectl get ingress -n cat-entertainment cat-game-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Check your cluster's ingress configuration")
fi
echo -e "${GREEN}http://$INGRESS_HOST${NC}"
echo -e "${GREEN}===========================================================${NC}"
