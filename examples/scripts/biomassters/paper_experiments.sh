#!/bin/bash

# Ensure the docker-compose service is running
COMPOSE_FILE="/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml"
SERVICE_NAME="terratorch"

declare -A CONFIG_DEVICE_MAP=(
    # ["terratorch/examples/confs/biomassters/final_experiments/1_biomassters_s2_4_step_lora_300.yaml"]=1
    # ["terratorch/examples/confs/biomassters/final_experiments/2_biomassters_s2_12_step_lora_300.yaml"]=2
    # ["terratorch/examples/confs/biomassters/final_experiments/3_biomassters_s1_s2_4_step_300.yaml"]=3
    # ["terratorch/examples/confs/biomassters/final_experiments/4_biomassters_s1_s2_12_step_300.yaml"]=0
    # ["terratorch/examples/confs/biomassters/final_experiments/5_biomassters_s1_s2_all_12_step_300.yaml"]=0
    # ["terratorch/examples/confs/biomassters/final_experiments/6_biomassters_s2_12_step_lora_300_50_subset.yaml"]=4
    # ["terratorch/examples/confs/biomassters/final_experiments/7_biomassters_s2_12_step_lora_300_20_subset.yaml"]=5
    # ["terratorch/examples/confs/biomassters/final_experiments/8_biomassters_s2_12_step_lora_300_10_subset.yaml"]=6
    # ["terratorch/examples/confs/biomassters/final_experiments/9_biomassters_s2_12_step_lora_300_05_subset.yaml"]=7
    ["terratorch/examples/confs/biomassters/final_experiments/10_biomassters_s2_4_step_lora_600.yaml"]=2
    # ["terratorch/examples/confs/biomassters/final_experiments/11_biomassters_s2_12_step_lora_600.yaml"]=2
    ["terratorch/examples/confs/biomassters/final_experiments/12_biomassters_s1_s2_4_step_600.yaml"]=3
    # ["terratorch/examples/confs/biomassters/final_experiments/13_biomassters_s1_s2_12_step_600.yaml"]=0
    # ["terratorch/examples/confs/biomassters/final_experiments/14_biomassters_s1_s2_all_12_step_600.yaml"]=0
    ["terratorch/examples/confs/biomassters/final_experiments/15_biomassters_s2_12_step_lora_600_50_subset.yaml"]=4
    ["terratorch/examples/confs/biomassters/final_experiments/16_biomassters_s2_12_step_lora_600_20_subset.yaml"]=5
    ["terratorch/examples/confs/biomassters/final_experiments/17_biomassters_s2_12_step_lora_600_10_subset.yaml"]=6
    ["terratorch/examples/confs/biomassters/final_experiments/18_biomassters_s2_12_step_lora_600_05_subset.yaml"]=7
)

repeats=1

run_experiment_repetitions() {
    local config_file=$1
    local device_id=$2
    local num_repeats=$3

    for i in $(seq 1 "$num_repeats"); do
        echo "--- Starting repetition $i of $num_repeats for ${config_file} on GPU ${device_id} ---"
        docker compose -f "${COMPOSE_FILE}" exec -T "${SERVICE_NAME}" bash -c "CUDA_VISIBLE_DEVICES=${device_id} terratorch fit -c ${config_file} --seed_everything $((i-1))"
        echo "--- Repetition $i for ${config_file} finished ---"
    done
}

pids=()
for config_file in "${!CONFIG_DEVICE_MAP[@]}"; do
    device_id=${CONFIG_DEVICE_MAP[$config_file]}
    echo "Starting experiment series for ${config_file} on GPU ${device_id}"
    run_experiment_repetitions "${config_file}" "${device_id}" "${repeats}" &
    pids+=($!)
done

for pid in "${pids[@]}"; do
    wait "$pid"
done

echo "All experiment series completed."

# e.g. running all configs wil1 result in these commands:
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=1 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/1_biomassters_s2_4_step_lora_300.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=2 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/2_biomassters_s2_12_step_lora_300.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=3 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/3_biomassters_s1_s2_4_step_300.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=0 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/4_biomassters_s1_s2_12_step_300.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=0 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/5_biomassters_s1_s2_all_12_step_300.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=4 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/6_biomassters_s2_12_step_lora_300_50_subset.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=5 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/7_biomassters_s2_12_step_lora_300_20_subset.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=6 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/8_biomassters_s2_12_step_lora_300_10_subset.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=7 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/9_biomassters_s2_12_step_lora_300_05_subset.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=1 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/10_biomassters_s2_4_step_lora_600.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=2 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/11_biomassters_s2_12_step_lora_600.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=3 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/12_biomassters_s1_s2_4_step_600.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=0 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/13_biomassters_s1_s2_12_step_600.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=0 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/14_biomassters_s1_s2_all_12_step_600.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=4 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/15_biomassters_s2_12_step_lora_600_50_subset.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=5 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/16_biomassters_s2_12_step_lora_600_20_subset.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=6 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/17_biomassters_s2_12_step_lora_600_10_subset.yaml"
# docker compose -f "/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml" exec -T terratorch bash -c "CUDA_VISIBLE_DEVICES=7 terratorch fit -c terratorch/examples/confs/biomassters/final_experiments/18_biomassters_s2_12_step_lora_600_05_subset.yaml"