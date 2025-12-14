#!/bin/bash
#SBATCH --job-name=download_reads
#SBATCH --partition=short
#SBATCH --time=1:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --output=log_%x_%j.out
#SBATCH --error=log_%x_%j.err

# Help message
show_help() {
  echo "Usage: $0 -s SRR -m maxSpotId"
  echo ""
  echo "Options:"
  echo "  -s, --sra    SRA ID"
  echo "  -m, --maxSpotId    Number of first m reads to download"
  echo "  -h, --help      Show this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--srr)
      SRA_ID="$2"
      shift 2
      ;;
    -m|--maxSpotId)
      maxSpotId="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# if run without SLURM
export SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK:-4}
export SLURM_MEM_PER_NODE=${SLURM_MEM_PER_NODE:-16000}

# Check required arguments
if [[ -z "$SRA_ID" || -z "$maxSpotId" ]]; then
  echo "Error: both --sra and --maxSpotId are required."
  show_help
  exit 1
fi


mkdir -p $SRA_ID
cd $SRA_ID

# Convert to split using fasterq-dump
date +"%D %T" | tr "\n" "  "; echo "fastq-dumping $SRA_ID"
fastq-dump --skip-technical --split-3 --maxSpotId $maxSpotId $SRA_ID

# Merge fastq
echo; date +"%D %T" | tr "\n" "  "; echo "Merging fastq"
cat ${SRA_ID}_1.fastq ${SRA_ID}_2.fastq > ${SRA_ID}_merged.fastq
rm ${SRA_ID}_1.fastq ${SRA_ID}_2.fastq

# Create reads kmer db
echo; date +"%D %T" | tr "\n" "  "; echo "Creating KMC db"
kmc \
    -t$SLURM_CPUS_PER_TASK \
    -k21 \
    -m$SLURM_MEM_PER_NODE \
    -ci0 \
    -cs10000000 \
    ${SRA_ID}_merged.fastq \
    ${SRA_ID} \
    ./
rm ${SRA_ID}_merged.fastq

echo; date +"%D %T" | tr "\n" "  "; echo "Done"