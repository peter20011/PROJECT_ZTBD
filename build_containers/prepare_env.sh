#!/bin/bash

# Sprawdzenie, czy docker jest zainstalowany
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

# Zapisanie ścieżki obecnego katalogu
current_dir=$(pwd)

# Sprawdzenie, czy p7zip-full jest zainstalowany, jeśli nie, to instalacja
if ! dpkg -l | grep -q p7zip-full; then
  sudo apt-get update
  sudo apt-get install -y p7zip-full
  if [ $? -ne 0 ]; then
    echo 'Error: Failed to install p7zip-full.' >&2
    exit 1
  fi
fi

# Rozpakowanie dump_mongo.7z, jeśli nie istnieje katalog dump_mongo
if [ ! -d "$current_dir/dump_mongo" ]; then
  if [ -f "dump_mongo.7z" ]; then
    7z x dump_mongo.7z
    if [ $? -ne 0 ]; then
      echo 'Error: Failed to unpack dump_mongo.7z.' >&2
      exit 1
    fi
  else
    echo 'Error: dump_mongo.7z not found.' >&2
    exit 1
  fi
fi

# Rozpakowanie dump_redis.7z, jeśli nie istnieje katalog dump_redis
if [ ! -d "$current_dir/dump_redis" ]; then
  if [ -f "dump_redis.7z" ]; then
    7z x dump_redis.7z
    if [ $? -ne 0 ]; then
      echo 'Error: Failed to unpack dump_redis.7z.' >&2
      exit 1
    fi
  else
    echo 'Error: dump_redis.7z not found.' >&2
    exit 1
  fi
fi

echo 'Setup completed successfully.'
