#!/bin/bash
#SBATCH --job-name=count_kmers
#SBATCH --partition=short
#SBATCH --time=1:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --output=log_%x_%j.out
#SBATCH --error=log_%x_%j.err

# Help message
show_help() {
  echo "Usage: $0 -s SAMPLE_NAME -k KMER_LIST"
  echo ""
  echo "Options:"
  echo "  -s, --sample    KMC database for the sample (input to intersect)"
  echo "  -k, --kmers     TSV file with kmers (two columns: ID and sequence)"
  echo "  -h, --help      Show this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--sample)
      sample_name="$2"
      shift 2
      ;;
    -k|--kmers)
      query_kmers="$2"
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

export SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK:-4}

# Check required arguments
if [[ -z "$sample_name" || -z "$query_kmers" ]]; then
  echo "Error: both --sample and --kmers are required."
  show_help
  exit 1
fi

cd $sample_name

# kmer list to fasta
awk '{print ">"$1"\n"$2}' "../$query_kmers" > query_kmers.fa

# create query kmer db
date +"%D %T" | tr "\n" "  "; echo "Creating query KMC db"
kmc -fa -k21 -ci0 query_kmers.fa query_kmers .

# intersect kmer dbs
echo; date +"%D %T" | tr "\n" "  "; echo "Intersecting KMC db"
kmc_tools \
  -t$SLURM_CPUS_PER_TASK \
  simple \
  "$sample_name" \
  query_kmers \
  intersect \
  common-kmers \
  -ocleft

# dump the intersection to a text file
kmc_tools \
  -t$SLURM_CPUS_PER_TASK \
  transform \
  common-kmers \
  dump \
  "$sample_name.cnt"

# output result
cat "$sample_name.cnt"

# clear
#rm query_kmers.fa query_kmers.kmc* common-kmers.kmc*