# count_kmers_in_reads_kmc

Download first m reads of SRA:
- `./download_reads.sh -s <SRA_ID> -m <maxSpotID>`

Count kmers
- `count_kmers.sh -s <SRA_ID> -k <kmers_tsv>`
- dir wit name <SRA_ID> must be in current dir
- kmers_tsv must have two columns (kmer_name, kmer_sequence) without header

To collect results of multiple run:
- `python3 collect_counts.sh -k <kmers_tsv> -s <srr_list>`
- srr_list must have sra ids in each line




for i in `cat srr_list.txt`; do ../download_reads.sh -s $i -m 100; done
for i in `cat srr_list.txt`; do ../count_kmers.sh -s $i -k kmers.tsv; done
python3 ../collect_counts.py -k kmers.tsv -s srr_list.txt