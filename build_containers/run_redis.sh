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

# Utworzenie pliku CSV i zapisanie nagłówka
echo $content > "$current_dir/output/$file_name"

for (( i=1; i<=$it; i++ ))
do
    docker run --rm -v "$current_dir/dump_redis/":/data -d redis:latest
    sleep 12  # Czas oczekiwania na pełne uruchomienie kontenera Redis
    container_id=$(docker ps -lq)

    # Sprawdzenie, czy kontener został uruchomiony
    if [ -z "$container_id" ]; then
        echo "Failed to start the Docker container."
        exit 1
    fi

    start_time=$(date +%s.%N)

    result=$(docker exec "$container_id" redis-cli $query 2>&1)
    query_status=$?

    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)

    echo "Result for iteration $i:"
    echo "$result"
    echo "Execution time: $execution_time seconds"

    # Append execution time to CSV file
    echo "$i,$execution_time" >> "$current_dir/output/$file_name"

    docker stop "$container_id"
done
