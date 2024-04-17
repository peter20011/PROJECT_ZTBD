#!/bin/bash

current_dir=$(pwd)
lua_script_path=$1  # Path to the LUA script
iteration_count=$2
output_file_name=$3

output_dir="${current_dir}/output"
output_file="${output_dir}/${output_file_name}.csv"

path_to_scripts="${current_dir}/scripts/${lua_script_path}"

# Ensure output directory exists
mkdir -p "${output_dir}"

# Create a CSV file if it doesn't exist and write the header
echo "Iteration,Execution Time" > "${output_file}"

for (( i=1; i<=iteration_count; i++ ))
do
    # Run Redis container
    docker run --rm -v "${current_dir}/dump_redis/:/data" -d redis:latest
    sleep 15  # Give time for Redis to start
    container_id=$(docker ps -lq)

    docker cp "${path_to_scripts}" $container_id:/data

    # Capture start time
    start_time=$(date +%s.%N)

    # Execute the LUA script in Redis
    result=$(docker exec $container_id redis-cli --eval /data/$lua_script_path , 2>&1)

    # Capture end time
    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)

    # Log results
    echo "Iteration $i, Result: $result, Execution time: $execution_time seconds"
    
    # Append execution time to CSV file
    echo "$i,$execution_time" >> "${output_file}"

    # Stop the Redis container
    docker stop $container_id
    sleep 5
done

echo "Script execution completed. Results saved to ${output_file}"
