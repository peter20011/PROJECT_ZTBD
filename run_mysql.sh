#!/bin/bash

current_dir=$(pwd)
query=$1

docker run -d --rm -v $current_dir/mysql:/docker-entrypoint-initdb.d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:latest
container_id=$(docker ps -lq)
#musi być sleep, żeby baza się zainicjalizowała
sleep 25

start_time=$(date +%s.%N)

# Otwórz kontener i wykonaj zapytanie SQL
result=$(docker exec $container_id mysql -e "$query" 2>&1)

end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)

echo "Result:"
echo "$result"
echo "Execution time: $execution_time seconds"

# Usuń kontener
docker stop $container_id
