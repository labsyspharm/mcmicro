#!/usr/bin/env bash
set -euo pipefail

GPU_PARTITION="${MGB_GPU_PARTITION:-gpu-l40s}"
GPU_GRES="${MGB_GPU_GRES:-gpu:nvidia_l40s:1}"
MGB_WORK_ROOT="${MGB_WORK_ROOT:-$HOME/scratch}"

echo "== Host =="
hostname
date

echo
echo "== User/account =="
id
groups

echo
echo "== Modules =="
module avail 2>&1 | grep -Ei 'apptainer|singularity|cuda|java|nextflow' || true

echo
echo "== Runtime commands =="
for cmd in java nextflow singularity apptainer; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '%-12s %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '%-12s not found\n' "$cmd"
  fi
done

echo
echo "== Versions =="
java -version 2>&1 || true
nextflow -version 2>&1 || true
singularity --version 2>&1 || apptainer --version 2>&1 || true

echo
echo "== Slurm partitions =="
sinfo -o "%P %a %l %D %N %G"

echo
echo "== GPU-looking Slurm resources =="
sinfo -o "%P %N %G %m %c" | grep -Ei 'gpu|a100|v100|l40|h100|tesla|rtx' || true

echo
echo "== Slurm association/QOS =="
sacctmgr show assoc user="$USER" format=Cluster,Account,Partition,QOS%40 || true
sacctmgr show user "$USER" withassoc format=User,DefaultAccount,Account,Partition,QOS%40 || true

echo
echo "== Filesystems =="
ls -ld "$HOME" "$HOME/scratch" "$MGB_WORK_ROOT" 2>/dev/null || true
df -h "$HOME" "$HOME/scratch" /data /scratch /n/scratch 2>/dev/null || true
findmnt -T "$HOME/scratch" -no TARGET,OPTIONS 2>/dev/null || true
printf 'TMPDIR=%s\n' "${TMPDIR:-}"
printf 'APPTAINER_TMPDIR=%s\n' "${APPTAINER_TMPDIR:-}"
printf 'APPTAINER_CACHEDIR=%s\n' "${APPTAINER_CACHEDIR:-}"
printf 'SINGULARITY_TMPDIR=%s\n' "${SINGULARITY_TMPDIR:-}"
printf 'SINGULARITY_CACHEDIR=%s\n' "${SINGULARITY_CACHEDIR:-}"

if [[ "${1:-}" == "--test-gpu" ]]; then
  echo
  echo "== GPU allocation test =="
  echo "Requesting partition=${GPU_PARTITION}, gres=${GPU_GRES}"
  srun -p "$GPU_PARTITION" --gres="$GPU_GRES" --pty bash -lc \
    'hostname; echo CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES; nvidia-smi'
fi
