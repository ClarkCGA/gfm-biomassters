# example run:
# CUDA_VISIBLE_DEVICES=0 terratorch test -c /opt/app-root/src/terratorch/examples/confs/biomassters/biomassters_s2_s1_12_step.yaml --ckpt_path /output/paper_experiments/s2_s1_12_step/version_0/checkpoints/best-epoch=159-val_RMSE=0.0000.ckpt
#!/bin/bash
# --- Host Paths ---
# Base directory where experiments are stored on the host
HOST_EXPERIMENT_BASE_DIR="/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters-output/paper_experiments"

# --- Container Paths (from compose.yml) ---
CONTAINER_OUTPUT_BASE_DIR="/output/paper_experiments"
CONTAINER_CONFIG_DIR="/opt/app-root/src/terratorch/examples/confs/biomassters"

# --- Docker Configuration ---
COMPOSE_FILE="/workspace/Denys/biomassters/gfm-biomassters-terratorch/gfm-biomassters/compose.yml"
DEVICE_ID=0

# Find all checkpoint files on the host and loop through them
find "${HOST_EXPERIMENT_BASE_DIR}" -name "*.ckpt" | while read -r HOST_CKPT_PATH; do
    # Extract the experiment name from the host path
    # e.g., /path/to/output/paper_experiments/s2_s1_12_step/version_0/... -> s2_s1_12_step
    EXP_NAME=$(echo "${HOST_CKPT_PATH}" | awk -F'/' '{print $(NF-3)}')
    CKPT_FILENAME=$(basename "${HOST_CKPT_PATH}")
    VERSION=$(echo "${HOST_CKPT_PATH}" | awk -F'/' '{print $(NF-2)}')

    CONTAINER_CONFIG_FILE="${CONTAINER_CONFIG_DIR}/biomassters_${EXP_NAME}.yaml"

    CONTAINER_CKPT_PATH="${CONTAINER_OUTPUT_BASE_DIR}/${EXP_NAME}/${VERSION}/checkpoints/${CKPT_FILENAME}"
    INNER_COMMAND="CUDA_VISIBLE_DEVICES=${DEVICE_ID} terratorch test -c ${CONTAINER_CONFIG_FILE} --ckpt_path ${CONTAINER_CKPT_PATH}"

    echo "---"
    echo "Executing test for ${INNER_COMMAND}"
    docker compose -f "${COMPOSE_FILE}" exec -T terratorch bash -c "${INNER_COMMAND}" < /dev/null
    echo "---"

done

echo "All tests completed."