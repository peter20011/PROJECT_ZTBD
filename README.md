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



Jak zamontować dump do MongoDB:

Stwórz kontener z dumpem mongo:

```bash
docker run -d --name mongo-container -v PATH_TO_MONGO_DUMP\:/dump mongo
```

Użyj mongoresotre by odtworzyć bazę dane:
```bash
docker exec mongo-container mongorestore --uri="mongodb://localhost:27017/olympics" /dump/
```

Połącz się z kontenerem za pomocą klienta mongo:

```bash
docker exec -it mongo-container mongosh
```

Jak zamontować dump do Redis:


Stwórz kontener z bazą redis:

```bash
docker run --name redis-container -p 6379:6379 -d redis --requirepass "your_password"
```

Skopiuj dumpa do wzkazanego katalogu dockera:

```bash
docker cp YOUR_PATH_TO_DUMP\dump.rdb redis-container:/data/
```


Następnie zrestatruj kontener z bazą Redis:

```bash
docker restart redis-container
```





