# Hasła

Zmienilismy hasła na `PolishMeYaya`

Korzystamy z `kubectl` oraz `helm` do wykonywania zadań.

# Misja 1

Configi Kubernetes znajdują się w folderze `misja_1`, a wszystkie uruchomione komendy w `deploy.sh`. Strona jest dostępna pod adresem http://ogloszenia-krytyczne.193.187.67.100.nip.io

# Misja specjalna

Configi Kubernetes znajdują się w folderze `misja_specjalna`, a wszystkie uruchomione komendy w `deploy.sh`. Strona wraz z sekretnym kodem jest widoczna wewnatrz klustra, a żeby ją podejrzeć wystarczy przekierowac port kubectlem kubectl port-forward svc/nginx-service -n secret-code 8080:80 i użyć przeglądarki pod adresem 'localhost:8080'. Typ usługi to ClusterIP, co oznacza, że jest ona osiągalna pod adresem DNS w formacie <nazwa-usługi>.<przestrzeń-nazw>.svc.cluster.local. W tym przypadku będzie to nginx-service.secret-code.svc.cluster.local.

# Misja 3

Configi Kubernetes znajdują się w folderze `misja_3`, a wszystkie uruchomione komendy w `deploy.sh`. Gra jest dostępna pod adresem http://193.187.67.100.nip.io/

# Misja 8

Wszustkie komendy znajdują się w `deploy.sh`

# Misja 9

Configi znajdują się w folderze `misja_9`, a wszystkie uruchomione komendy w `deploy.sh`. Strona jest dostępna pod adresem http://pdsddi.193.187.67.100.nip.io/ _albo i nie bo nie dziala_
