from Bio.Seq import Seq
import pandas as pd
import argparse


def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Process kmer counts from SRR files')
    parser.add_argument('--kmer_file', '-k', type=str, default='kmers.tsv',
                       help='Path to kmer TSV file (default: kmers.tsv)')
    parser.add_argument('--srr_list_file', '-s', type=str, default='srr_list.txt',
                       help='Path to SRR list file (default: srr_list.txt)')
    parser.add_argument('--output', '-o', type=str, default='counts.tsv',
                       help='Output file name (default: counts.tsv)')
    
    # Parse arguments
    args = parser.parse_args()
    
    # Read SRR list from file
    srr_list = []
    with open(args.srr_list_file) as f:
        for line in f:
            srr_list.append(line.strip())
    
    # Read kmer file
    kmer_df = pd.read_csv(args.kmer_file, sep='\t', names=['name', 'kmer']).set_index('kmer')
    
    # Process each SRR
    all_counts = pd.DataFrame()
    for srr in srr_list:
        srr_counts = pd.read_csv(f'{srr}/{srr}.cnt', sep='\t', names=['kmer', srr]).set_index('kmer')
        all_counts = pd.concat([all_counts, srr_counts], axis=1)
    
    # Handle reverse complements
    for kmer in all_counts.index:
        if kmer in kmer_df.index:
            all_counts.loc[kmer, 'kmer'] = kmer
        else:
            all_counts.loc[kmer, 'kmer'] = str(Seq(kmer).reverse_complement())
    
    # Reorganize data
    all_counts = all_counts.set_index('kmer')
    all_counts = pd.concat([all_counts, kmer_df], axis=1)
    all_counts = all_counts.fillna(0)
    
    # Save output
    all_counts.to_csv(args.output, sep='\t')
    print(f"Output saved to {args.output}")


if __name__ == '__main__':
    main()