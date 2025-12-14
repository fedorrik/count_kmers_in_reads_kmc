# count_kmers_in_reads_kmc

Download first m reads of SRA and convert to KMC db:
- `./download_reads.sh -s <SRA_ID> -m <maxSpotID>`

Count kmers in KMC db
- `count_kmers.sh -s <SRA_ID> -k <kmers_tsv>`
- dir wit name <SRA_ID> must be in current dir
- kmers_tsv must have two columns (kmer_name, kmer_sequence) without header

Collect results of multiple run:
- `python3 collect_counts.sh -k <kmers_tsv> -s <srr_list>`
- srr_list must have sra ids in each line

Example in ./test:

- `while read i; do ../download_reads.sh -s $i -m 100; done < srr_list.txt`
- `while read i; do ../count_kmers.sh -s $i -k kmers.tsv; done < srr_list.txt`
- `python3 ../collect_counts.py -k kmers.tsv -s srr_list.txt`