#!/bin/bash

current_dir=$(pwd)
query=$1
it=$2
file_name=$3
content="Iteration,$file_name"
file_name="$file_name.csv"

echo $content > output/$file_name

for (( i=1; i<=$it; i++ ))
do
    docker run -d --rm -v $current_dir/dump_mongo:/docker-entrypoint-initdb.d mongo:latest
    container_id=$(docker ps -lq)
    docker exec $(docker ps -lq) mongorestore --uri="mongodb://localhost:27017/olympics" /docker-entrypoint-initdb.d/olympics > /dev/null

    start_time=$(date +%s.%N)

    result=$(docker exec $container_id mongosh olympics --eval "$query" 2>&1)

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
