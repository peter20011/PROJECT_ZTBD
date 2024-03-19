# Sprawdzenie, czy docker jest zainstalowany
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

# Zapisanie ścieżki obecnego katalogu
current_dir=$(pwd)

#Instaluje 7zipa
sudo apt-get install p7zip-full

# Rozpakowanie dump_mongo.7z, jeśli nie istnieje katalog dump_mongo
if [ ! -d "$current_dir/dump_mongo" ]; then
  7z x dump_mongo.7z
fi

# Rozpakowanie dump_redis.7z, jeśli nie istnieje katalog dump_redis
if [ ! -d "$current_dir/dump_redis" ]; then
  7z x dump_redis.7z
fi

# Stworzenie kontenera z mysql i mariadb z plikami inicjalizacyjnymi
docker run -v $current_dir/mysql:/docker-entrypoint-initdb.d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d mysql:latest
docker run -v $current_dir/mariadb:/docker-entrypoint-initdb.d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d mariadb:latest

# Stworzenie kontenera z mongodb
docker run -d -v $current_dir/dump_mongo:/docker-entrypoint-initdb.d mongo:latest
docker exec $(docker ps -lq) mongorestore --uri="mongodb://localhost:27017/olympics" /docker-entrypoint-initdb.d/olympics


#Zbuduj kontener redisa
docker run -v ./dump_redis:/data -d redis:latest --appendonly yes
docker restart $(docker ps -lq)

