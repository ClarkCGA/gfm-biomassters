#!/bin/bash

# Ensure the docker-compose service is running
docker compose up -d

CONFIGS=(
    "terratorch/examples/confs/biomassters/biomassters_s2_12_step.yaml"
    "terratorch/examples/confs/biomassters/biomassters_s2_4_step.yaml"
    "terratorch/examples/confs/biomassters/biomassters_s2_s1_12_step.yaml"
    "terratorch/examples/confs/biomassters/biomassters_s2_s1_4_step.yaml"
)
DEVICES=(0 1 2 3)
REPEATS=5

for i in $(seq 1 $REPEATS); do
    echo "--- Starting repetition $i of $REPEATS ---"
    pids=()
    for j in "${!CONFIGS[@]}"; do
        CONFIG_FILE=${CONFIGS[$j]}
        DEVICE_ID=${DEVICES[$j]}
        
        echo "Starting ${CONFIG_FILE} on GPU ${DEVICE_ID}"
        
        # The command is now simpler as the venv is active by default
        docker compose exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=${DEVICE_ID} terratorch fit -c ${CONFIG_FILE} --seed_everything $i" &
        pids+=($!)
    done

    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    echo "--- Repetition $i finished ---"
done

echo "All repetitions completed."
# docker compose down