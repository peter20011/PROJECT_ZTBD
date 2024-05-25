#!/bin/bash

set -e

current_dir=$(pwd)
query=$1
iterations=$2
file_name=$3
csv_file="output/${file_name}.csv"
content="Iteration,${file_name}"

# Create output directory if it doesn't exist
mkdir -p output

# Create a CSV file if it doesn't exist and write the header
if [ ! -f "$csv_file" ]; then
    echo "$content" > "$csv_file"
fi

for (( i=1; i<=$iterations; i++ ))
do
    container_id=$(docker run -d --rm -v "${current_dir}/mariadb:/docker-entrypoint-initdb.d" -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mariadb:latest)

    echo "Waiting for the database to initialize..."
    while ! docker exec "$container_id" mariadb -e "SELECT 1" &>/dev/null; do
        sleep 1
    done

    start_time=$(date +%s.%N)

    # Execute the SQL query
    result=$(docker exec "$container_id" mariadb -e "$query" 2>&1)
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

    # Append execution time to CSV file
    echo "$i,$execution_time" >> "$csv_file"

    # Stop and remove the container
    docker stop "$container_id"
done
