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