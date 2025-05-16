# Hasła

Zmienilismy hasła na `PolishMeYaya`

# Misja 1

Configi Kubernetes znajdują się w folderze `misja_1`, a wszystkie uruchomione komendy w `deploy.sh`. Strona jest dostępna pod adresem http://ogloszenia-krytyczne.193.187.67.100.nip.io

# Misja specjalna

Configi Kubernetes znajdują się w folderze `misja_specjalna`, a wszystkie uruchomione komendy w `deploy.sh`. Strona wraz z sekretnym kodem jest widoczna wewnatrz klustra, a żeby ją podejrzeć wystarczy przekierowac port kubectlem kubectl port-forward svc/nginx-service -n secret-code 8080:80 i użyć przeglądarki pod adresem 'localhost:8080'.
