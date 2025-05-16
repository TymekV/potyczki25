#!/bin/bash
# deploy.sh - Creates resources for the rapid response team with minimal permissions
# according to zero-trust principle

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Starting Misja 8 - 'Rapid Response Team Access'"
echo "Setting up read-only access to logs for the rapid response team"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

# Check if namespace exists, create if it doesn't
echo "Checking if namespace 'ogloszenia-krytyczne' exists..."
if ! kubectl get namespace ogloszenia-krytyczne &> /dev/null; then
    echo "Creating namespace 'ogloszenia-krytyczne'..."
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ogloszenia-krytyczne
EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Namespace 'ogloszenia-krytyczne' created successfully.${NC}"
    else
        echo -e "${RED}Error: Failed to create namespace 'ogloszenia-krytyczne'.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Namespace 'ogloszenia-krytyczne' already exists.${NC}"
fi

# Create a ClusterRole for the user 'rapid-response-agent'
echo "Creating ClusterRole for user 'rapid-response-agent'..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: readonly-logs-role
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]
EOF

# Create a ClusterRoleBinding for the user 'rapid-response-agent'
echo "Creating ClusterRoleBinding for user 'rapid-response-agent'..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rapid-response-agent-binding
  namespace: ogloszenia-krytyczne
subjects:
- kind: User
  name: rapid-response-agent
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: readonly-logs-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Create a namespaced Role 'log-reader' with minimal permissions
echo "Creating Role 'log-reader' in namespace 'ogloszenia-krytyczne'..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: log-reader
  namespace: ogloszenia-krytyczne
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
EOF

# Create a ServiceAccount 'automated-response-agent'
echo "Creating ServiceAccount 'automated-response-agent'..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: automated-response-agent
  namespace: ogloszenia-krytyczne
EOF

# Create a RoleBinding for the ServiceAccount
echo "Creating RoleBinding for 'automated-response-agent'..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: automated-response-agent-binding
  namespace: ogloszenia-krytyczne
subjects:
- kind: ServiceAccount
  name: automated-response-agent
  namespace: ogloszenia-krytyczne
roleRef:
  kind: Role
  name: log-reader
  apiGroup: rbac.authorization.k8s.io
EOF

# Verify the created resources
echo "Verifying created resources..."

echo "Checking ClusterRole 'readonly-logs-role'..."
if kubectl get clusterrole readonly-logs-role &> /dev/null; then
    echo -e "${GREEN}ClusterRole 'readonly-logs-role' created successfully.${NC}"
else
    echo -e "${RED}Error: ClusterRole 'readonly-logs-role' was not created.${NC}"
fi

echo "Checking RoleBinding 'rapid-response-agent-binding'..."
if kubectl get rolebinding -n ogloszenia-krytyczne rapid-response-agent-binding &> /dev/null; then
    echo -e "${GREEN}RoleBinding 'rapid-response-agent-binding' created successfully.${NC}"
else
    echo -e "${RED}Error: RoleBinding 'rapid-response-agent-binding' was not created.${NC}"
fi

echo "Checking Role 'log-reader'..."
if kubectl get role -n ogloszenia-krytyczne log-reader &> /dev/null; then
    echo -e "${GREEN}Role 'log-reader' created successfully.${NC}"
else
    echo -e "${RED}Error: Role 'log-reader' was not created.${NC}"
fi

echo "Checking ServiceAccount 'automated-response-agent'..."
if kubectl get serviceaccount -n ogloszenia-krytyczne automated-response-agent &> /dev/null; then
    echo -e "${GREEN}ServiceAccount 'automated-response-agent' created successfully.${NC}"
else
    echo -e "${RED}Error: ServiceAccount 'automated-response-agent' was not created.${NC}"
fi

echo "Checking RoleBinding 'automated-response-agent-binding'..."
if kubectl get rolebinding -n ogloszenia-krytyczne automated-response-agent-binding &> /dev/null; then
    echo -e "${GREEN}RoleBinding 'automated-response-agent-binding' created successfully.${NC}"
else
    echo -e "${RED}Error: RoleBinding 'automated-response-agent-binding' was not created.${NC}"
fi

# Print usage instructions
echo -e "${GREEN}===========================================================${NC}"
echo -e "${GREEN}Mission 8 - 'Rapid Response Team Access' completed successfully!${NC}"
echo -e "${GREEN}===========================================================${NC}"
echo "The following resources have been created:"
echo "1. User 'rapid-response-agent' with read-only access to pods and their logs in 'ogloszenia-krytyczne' namespace"
echo "2. Role 'log-reader' in 'ogloszenia-krytyczne' namespace with permissions to get/list pods and access logs"
echo "3. ServiceAccount 'automated-response-agent' with the 'log-reader' role"
echo ""
echo "Example commands for the rapid response team:"
echo "kubectl get pods -n ogloszenia-krytyczne"
echo "kubectl logs <pod-name> -n ogloszenia-krytyczne"
echo -e "${GREEN}===========================================================${NC}"