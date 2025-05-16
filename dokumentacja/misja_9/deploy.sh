#!/bin/bash

# Skrypt do wdrożenia WordPressa w przestrzeni nazw pdsddi

# Utworzenie przestrzeni nazw
kubectl apply -f namespace.yaml

# Utworzenie sekretów dla MySQL
kubectl apply -f mysql-secret.yaml

# Utworzenie PersistentVolumeClaims dla MySQL i WordPressa
kubectl apply -f mysql-pvc.yaml
kubectl apply -f wordpress-pvc.yaml

# Wdrożenie MySQL
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

# Oczekiwanie na gotowość MySQL (prosta pętla, w produkcji rozważ bardziej zaawansowane sprawdzanie)

# Wdrożenie WordPressa
kubectl apply -f wordpress-deployment.yaml
kubectl apply -f wordpress-service.yaml

# Oczekiwanie na gotowość WordPressa

# Wdrożenie Ingressa
kubectl apply -f wordpress-ingress.yaml

