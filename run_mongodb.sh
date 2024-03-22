#!/bin/bash

current_dir=$(pwd)
query=$1

docker run -d --rm -v $current_dir/dump_mongo:/docker-entrypoint-initdb.d mongo:latest
docker exec $(docker ps -lq) mongorestore --uri="mongodb://localhost:27017/olympics" /docker-entrypoint-initdb.d/olympics > /dev/null

start_time=$(date +%s.%N)

result=$(docker exec $(docker ps -lq) mongosh olympics --eval "$query" 2>&1)

end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)

echo "Result:"
echo "$result"
echo "Execution time: $execution_time seconds"

docker stop $(docker ps -lq)
