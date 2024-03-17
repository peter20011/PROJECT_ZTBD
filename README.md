## Projekt zaliczeniowy z przedmiotu ZTBD

Jak stworzyć kontenery mariadb i mysql?

Pobierz repozytorium:

```bash
git clone https://github.com/peter20011/PROJECT_ZTBD.git
```
```
cd PROJECT_ZTBD
```
Użyj skryptu:

```bash
bash create_containers.sh
```

Skrypt sprawdza czy zainstalowany docker. Nastepnie tworzy kontenery mariadb i mysql. Jeśli obrazy nie są pobrane, to zaciąga najnowsze.
W obu kontenerach zostanie stworzona baza "olympics" podczas inicializacji (bardzo szybka inicjalizacja, więc można tworzyć nowy kontener zawsze gdy potrzebny oryginalny stan bazy danych).

Można przetestować tworzenie bazy danych na kontenerze np. mariadb:

```bash
docker exec -it $id_kontenera_mariadb mariadb
```
```
USE olympics;
SHOW TABLES;
```



