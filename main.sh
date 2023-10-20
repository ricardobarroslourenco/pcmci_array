#!/bin/bash

# Example of Slurm job array, adapted from The Alliance documentation (https://docs.alliancecan.ca/wiki/Job_arrays).
# Every task is self-contained (not depending on other tasks). Be careful to environment setup.

# Generate a comma-separated list of indices from the CSV file index column
indices=$(cut -d, -f1 parameters.csv | sort -n | tr '\n' ',' | sed 's/,$//')

# The indices list is then consumed by the slurm --array argument,
# which for every task, gets into a Slurm Array Task ID
# The --time flag, is max time per task (default below 3h to get higher priority)

#SBATCH --job-name=ja_ex
#SBATCH --output=out_%j.txt
#SBATCH --error=err_%j.txt
#SBATCH --array=${indices}
#SBATCH --time=00:30:00
#SBATCH --account=def-ggalex
#SBATCH --mem-per-cpu=2G   # 2 GB of memory per CPU
#SBATCH --cpus-per-task=4  # 4 CPUs per task

# Load python 3.11.5 (please customize given your workload - perhaps with a python venv)
module load StdEnv/2023 python/3.11.5

# Fetch the corresponding csv line based on the index value
eval $(awk -v var=$SLURM_ARRAY_TASK_ID -F, '$1==var {printf "index=%d temperature=%.1f category=%s", $1, $2, $3}' parameters.csv)

# Running the python script with the extracted parameters
python main.py --index "$index" --temperature "$temperature" --category "$category"