#!/bin/bash

current_dir=$(pwd)
query=$1

docker run --rm -v $current_dir/dump_redis:/data -d redis:latest --appendonly yes
container_id=$(docker ps -lq)

start_time=$(date +%s.%N)

result=$(docker exec $container_id redis-cli "$query" 2>&1)

end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)

echo "Result:"
echo "$result"

echo "Execution time: $execution_time seconds"

docker stop $container_id