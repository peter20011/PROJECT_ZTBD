# Sprawdzenie, czy docker jest zainstalowany
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

# Zapisanie ścieżki obecnego katalogu
current_dir=$(pwd)

# Stworzenie kontenera z mysql i mariadb z plikami inicjalizacyjnymi
docker run -v $current_dir/mysql:/docker-entrypoint-initdb.d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d mysql:latest
docker run -v $current_dir/mariadb:/docker-entrypoint-initdb.d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d mariadb:latest



