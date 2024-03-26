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
    docker run --rm -v $current_dir/dump_redis/:/data -d redis:latest
    sleep 12
    container_id=$(docker ps -lq)

    start_time=$(date +%s.%N)

    result=$(docker exec $container_id redis-cli $query 2>&1)

    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)

    echo "Result for iteration $i:"
    echo "$result"
    echo "Execution time: $execution_time seconds"

    # Append execution time to CSV file
    echo "$i,$execution_time" >> output/$file_name

    docker stop $container_id
done
