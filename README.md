# Prithvi BioMassters Experiments in Terratorch
## Overview
This repository adapts TerraTorch to compare the performance of Prithvi GFM on the BioMassters benchmark dataset. TerraTorch is a PyTorch domain library based on [PyTorch Lightning](https://lightning.ai/docs/pytorch/stable/) and the [TorchGeo](https://github.com/microsoft/torchgeo) domain library
for geospatial data.

## Instructions
To replicate experiments as performed after cloning this repository to the host machine:
1. Download the BioMassters dataset from Huggingface: https://huggingface.co/datasets/ibm-nasa-geospatial/BioMassters to the host machine.
2. Modify the paths in the ```compose.yml``` volumes to match each directory on the host machine.
3. Run the command: ```docker compose up -d``` in the repository. This will build the docker image and start the service. Note that, since the image installs Terratorch in editable mode each time it is run, the terratorch command will not be available in the container until 5-10 minutes after it starts. The availablility of terratorch can be confirmed by opening a bash terminal in the container, activating the venv by running ```source venv/bin/activate```, and running ```terratorch -h```.
4. Run ```pip install terratorch[peft]``` once terratorch has been installed.
5. The script for running all Biomassters experiments is ```examples/scripts/biomassters/paper_experiments.sh```. The configuration files are in ```examples/confs/biomassters/final_experiments.sh```. Which GPU each experiment runs on can be changed within ```paper_experiments.sh```, certain experiments can be turned on and off by commenting them out, and batch size can be customized within each configuration file. Modify these to run the desired experiments with the desired batch sizes on the desired GPUs, and modify the ```paper_experiments.sh``` script to reflect the correct path to the ```compose.yml``` on the host machine.
5. Navigate to ```examples/scripts/biomassters/``` on the host machine and run ```chmod +x paper_experiments.sh``` to make the paper experiment script executable. Then, run ```./paper_experiments.sh``` in the terminal on the host machine. This will execute all specified experiments.
6. After experiments complete, all checkpoints can be tested on the test set using the ```examples/scripts/biomassters/test_all.sh``` script.
7. If outputs of the baseline on the test set have been generated, figures may be generated using the ```examples/scripts/biomassters/create_figures.py``` script, which can be run from within the container.

