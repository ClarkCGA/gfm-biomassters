#!/bin/bash
# example run:
# CUDA_VISIBLE_DEVICES=0 terratorch test -c /opt/app-root/src/terratorch/examples/confs/biomassters/final_experiments/1_biomassters_s2_4_step_lora_300.yaml --ckpt_path /output/final_experiments/1_biomassters_s2_4_step_lora_300/version_0/checkpoints/best-epoch=46-val_RMSE=0.0000.ckpt --trainer.logger=CSVLogger
# prediction:
# CUDA_VISIBLE_DEVICES=0 terratorch predict -c /opt/app-root/src/terratorch/examples/confs/biomassters/final_experiments/1_biomassters_s2_4_step_lora_300.yaml --ckpt_path /output/final_experiments/1_biomassters_s2_4_step_lora_300/version_0/checkpoints/best-epoch=46-val_RMSE=0.0000.ckpt --predict_output_dir /output/final_experiments/1_biomassters_s2_4_step_lora_300/version_0/predictions 


COMPOSE_FILE="/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml"
SERVICE_NAME="terratorch3"

declare -a EXPERIMENTS=(
    "1_biomassters_s2_4_step_lora_300"
    "2_biomassters_s2_12_step_lora_300"
    "3_biomassters_s1_s2_4_step_300"
    "4_biomassters_s1_s2_12_step_300"
    "5_biomassters_s1_s2_all_12_step_300"
    "6_biomassters_s2_12_step_lora_300_50_subset"
    "7_biomassters_s2_12_step_lora_300_20_subset"
    "8_biomassters_s2_12_step_lora_300_10_subset"
    "9_biomassters_s2_12_step_lora_300_05_subset"
    # "10_biomassters_s2_4_step_lora_600"
    # "11_biomassters_s2_12_step_lora_600"
    # "12_biomassters_s1_s2_4_step_600"
    # "13_biomassters_s1_s2_12_step_600"
    # "14_biomassters_s1_s2_all_12_step_600"
    # "15_biomassters_s2_12_step_lora_600_50_subset"
    # "16_biomassters_s2_12_step_lora_600_20_subset"
    # "17_biomassters_s2_12_step_lora_600_10_subset"
    # "18_biomassters_s2_12_step_lora_600_05_subset"
)

CONTAINER_OUTPUT_BASE_DIR="/output/final_experiments"
CONTAINER_CONFIG_DIR="/opt/app-root/src/terratorch/examples/confs/biomassters/final_experiments"

for EXP_NAME in "${EXPERIMENTS[@]}"; do
    CONFIG_FILE="${CONTAINER_CONFIG_DIR}/${EXP_NAME}.yaml"

    # Loop over all versions for this experiment
    for VERSION_DIR in /workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters-output/final_experiments/${EXP_NAME}/version_*; do
        # Check if directory exists
        if [[ ! -d "$VERSION_DIR" ]]; then
            continue
        fi

        # Find checkpoint in this version
        CKPT_PATH_ON_HOST=$(find "$VERSION_DIR/checkpoints" -type f -name "*.ckpt" | sort | head -n 1)
        if [[ -z "$CKPT_PATH_ON_HOST" ]]; then
            echo "No checkpoint found for ${EXP_NAME} in ${VERSION_DIR}, skipping."
            continue
        fi

        VERSION=$(basename "$VERSION_DIR")
        CKPT_FILENAME=$(basename "${CKPT_PATH_ON_HOST}")
        CONTAINER_CKPT_PATH="${CONTAINER_OUTPUT_BASE_DIR}/${EXP_NAME}/${VERSION}/checkpoints/${CKPT_FILENAME}"

        INNER_COMMAND="CUDA_VISIBLE_DEVICES=2 terratorch test -c ${CONFIG_FILE} --ckpt_path ${CONTAINER_CKPT_PATH} --trainer.logger=CSVLogger"

        echo "---"
        echo "Executing test for ${INNER_COMMAND}"
        docker compose -f "${COMPOSE_FILE}" exec -T "${SERVICE_NAME}" bash -c "${INNER_COMMAND}"
        echo "---"
    done
done

echo "All tests completed."