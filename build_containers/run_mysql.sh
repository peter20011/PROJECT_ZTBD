#!/bin/bash

current_dir=$(pwd)
query=$1
it=$2
file_name=$3
content="Iteration,$file_name"
file_name="$file_name.csv"

# Create a CSV file if it doesn't exist and write the header
echo $content > output/$file_name

for (( i=1; i<=$it; i++ ))
do
    docker run -d --rm -v $current_dir/mysql:/docker-entrypoint-initdb.d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:latest
    container_id=$(docker ps -lq)
    # Must sleep to allow the database to initialize
    sleep 30

    start_time=$(date +%s.%N)

    # Open the container and execute the SQL query
    result=$(docker exec $container_id mysql -e "$query" 2>&1)

    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)

    echo "Result for iteration $i:"
    echo "$result"
    echo "Execution time: $execution_time seconds"

    # Append execution time to CSV file
    echo "$i,$execution_time" >> output/$file_name

    # Stop and remove the container
    docker stop $container_id
done

