#!/bin/bash

current_dir=$(pwd)
query=$1
it=$2
file_name=$3
content="Iteration,ExecutionTime"
file_name="$file_name.csv"

# Sprawdzenie, czy katalog output istnieje
if [ ! -d "$current_dir/output" ]; then
    mkdir -p "$current_dir/output"
fi

echo $query

# Utworzenie pliku CSV i zapisanie nagłówka
echo $content > "$current_dir/output/$file_name"

for (( i=1; i<=$it; i++ ))
do
    docker run -d --rm -v "$current_dir/mysql":/docker-entrypoint-initdb.d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:latest
    container_id=$(docker ps -lq)

    # Sprawdzenie, czy kontener został uruchomiony
    if [ -z "$container_id" ]; then
        echo "Failed to start the Docker container."
        exit 1
    fi

    # Musi spać, aby umożliwić zainicjowanie bazy danych
    sleep 30

    start_time=$(date +%s.%N)

    # Otwórz kontener i wykonaj zapytanie SQL
    result=$(docker exec "$container_id" mysql -e "$query" 2>&1)
    query_status=$?

    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)

    echo "Result for iteration $i:"
    echo "$result"
    echo "Execution time: $execution_time seconds"

    if [ $query_status -eq 0 ]; then
        echo "Query executed successfully."
    else
        echo "Query execution failed with status $query_status."
    fi

    # Dodanie czasu wykonania do pliku CSV
    echo "$i,$execution_time" >> "$current_dir/output/$file_name"

    # Zatrzymaj i usuń kontener
    docker stop "$container_id"
done
