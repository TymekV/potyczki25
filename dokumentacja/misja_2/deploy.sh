#!/bin/bash

# Skrypt do instalacji Longhorn (Misja 2 - "Long Horn")

# Upewnij się, że kontekst kubectl jest ustawiony na klaster "potyczki"
# Przykład: kubectl config use-context potyczki
echo "Upewnij się, że używasz kontekstu klastra 'potyczki'."
echo "Aktualny kontekst: $(kubectl config current-context)"
echo "Jeśli jest inny niż 'potyczki', zmień go poleceniem: kubectl config use-context potyczki"
echo ""

# 1. Dodaj repozytorium Helm Longhorn
echo "Dodawanie repozytorium Helm Longhorn..."
helm repo add longhorn https://charts.longhorn.io
if [ $? -ne 0 ]; then
    echo "Błąd podczas dodawania repozytorium Helm Longhorn. Sprawdź, czy Helm jest poprawnie zainstalowany i skonfigurowany."
    # exit 1 # Nie przerywamy, jeśli repo już istnieje
fi
echo "Dodano repozytorium Helm Longhorn (lub już istniało)."
echo ""

# 2. Zaktualizuj informacje o repozytoriach Helm
echo "Aktualizowanie repozytoriów Helm..."
helm repo update
if [ $? -ne 0 ]; then
    echo "Błąd podczas aktualizacji repozytoriów Helm."
    exit 1
fi
echo "Zaktualizowano repozytoria Helm."
echo ""

# 3. Sprawdź, czy Longhorn jest już zainstalowany i odinstaluj, jeśli tak
echo "Sprawdzanie, czy Longhorn jest już zainstalowany..."
if helm status longhorn -n longhorn-system &> /dev/null; then
    echo "Longhorn jest już zainstalowany. Próba odinstalowania..."
    helm uninstall longhorn -n longhorn-system
    # Czasami zadanie deinstalacyjne Helm może się zawiesić lub zakończyć błędem
    # Usuwamy je, jeśli istnieje, aby nie blokowało dalszych operacji
    echo "Usuwanie zadania deinstalacyjnego Helm 'longhorn-uninstall', jeśli istnieje..."
    kubectl delete job/longhorn-uninstall -n longhorn-system --ignore-not-found=true

    echo "Oczekiwanie na zakończenie usuwania zasobów Longhorn..."

    # Usuwanie CRD Longhorn - to często pomaga w odblokowaniu usuwania namespace
    echo "Usuwanie definicji zasobów niestandardowych (CRD) Longhorn..."
    kubectl get crd -o name | grep 'longhorn\.io' | xargs -r kubectl delete --ignore-not-found=true

    # Usuwanie finalizerów z PV, które mogły zostać osierocone (opcjonalne, ale może pomóc)
    # echo "Usuwanie finalizerów z osieroconych PersistentVolumes Longhorn..."
    # kubectl get pv -o name | grep -E 'pvc-|longhorn' | xargs -r kubectl patch -p '{"metadata":{"finalizers":null}}' --type=merge

    echo "Próba usunięcia przestrzeni nazw longhorn-system..."
    kubectl delete namespace longhorn-system --force --grace-period=0 --wait=true --ignore-not-found=true
    
    # Dodatkowe oczekiwanie, aby dać klastrowi czas na przetworzenie usunięcia
    sleep 15 

    echo "Poprzednia instalacja Longhorn (lub jej pozostałości) została usunięta."
else
    echo "Longhorn nie jest zainstalowany lub nie znaleziono wydania o nazwie 'longhorn' w namespace 'longhorn-system'."
    # Na wszelki wypadek, jeśli namespace istnieje bez wydania Helm
    echo "Próba usunięcia przestrzeni nazw longhorn-system, jeśli istnieje..."
    kubectl delete namespace longhorn-system --force --grace-period=0 --wait=true --ignore-not-found=true
    sleep 5
fi
echo ""

# 4. Zainstaluj Longhorn
# Użyj najnowszej stabilnej wersji Longhorn.
# Możesz sprawdzić dostępne wersje poleceniem: helm search repo longhorn/longhorn --versions
# Poniżej użyto przykładowej wersji. Zalecane jest sprawdzenie i użycie najnowszej dostępnej stabilnej wersji.
# Na dzień tworzenia skryptu (Maj 2025), jedną z nowszych wersji może być np. 1.6.x. Proszę zweryfikować.
# Załóżmy, że najnowsza stabilna wersja to 1.6.2 (należy to zweryfikować)
LONGHORN_VERSION="1.6.2" # WAŻNE: Sprawdź i zaktualizuj do najnowszej stabilnej wersji!

echo "Instalowanie Longhorn w wersji $LONGHORN_VERSION..."
echo "Namespace: longhorn-system (zostanie utworzony, jeśli nie istnieje)"
echo "Domyślna klasa przechowywania: true"
echo "Liczba replik: 1"
echo "Polityka lokalności danych: best-effort (zalecane dla klastrów z jednym węzłem)"

helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --set persistence.defaultClass=true \
  --set defaultSettings.defaultReplicaCount=1 \
  --set defaultSettings.defaultDataLocality="best-effort" \
  --version $LONGHORN_VERSION

if [ $? -ne 0 ]; then
    echo "Błąd podczas instalacji Longhorn. Sprawdź logi Helm dla szczegółów."
    exit 1
fi

echo ""
echo "Instalacja Longhorn została zainicjowana."
echo "Proces wdrożenia może potrwać kilka minut."
echo ""
echo "Aby sprawdzić status wdrożenia komponentów Longhorn, użyj polecenia:"
echo "  kubectl -n longhorn-system get pods --watch"
echo ""
echo "Po pomyślnej instalacji i uruchomieniu wszystkich podów, Longhorn powinien stać się domyślną klasą przechowywania."
echo "Możesz to zweryfikować poleceniem:"
echo "  kubectl get storageclass"
echo "Powinna istnieć klasa 'longhorn' oznaczona jako '(default)'."
echo ""
echo "Dostęp do interfejsu użytkownika Longhorn (jeśli usługa jest wystawiona, np. przez NodePort lub Ingress):"
echo "  kubectl -n longhorn-system get svc"
echo ""
echo "Misja 2 zakończona pomyślnie, jeśli aplikacja storage działa, a StorageClass 'longhorn' jest dostępna i domyślna."
