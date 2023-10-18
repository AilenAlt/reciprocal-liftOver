#!/bin/bash

# Program to perform reciprocal-liftOver on a BED file.
# In cross-species comparisons, using reciprocal-liftOver results in 1:1 relationships between sequences.
# Reciprocal liftover ensures that each genomic element in the original species corresponds to a unique 
# element in the target species and vice versa.

# Dependencies: liftover, bedmap (part of BEDOPS), sort-bed (part of BEDOPS), awk

# Parameters:
# BED: Input BED file to be lifted over
# CHAINFILE: Chain file for liftOver
# SWAPPED_CHAINFILE: Chain file for swapping lifted-over coordinates
# W: Minimum match ratio for liftOver

# Usage: bash reciprocal_liftOver.sh <BED> <CHAINFILE> <SWAPPED_CHAINFILE> <W>

# Example usage: bash reciprocal_liftOver.sh input.bed hg19ToHg38.over.chain hg38ToHg19.over.chain 0.95

BED=$1
CHAINFILE=$2
SWAPPED_CHAINFILE=$3
W=$4

FILEID=$(basename "$1" .bed)

liftOver -bedPlus=3 -minMatch=$4 $1 $2 "$FILEID"_res.bed "$FILEID"_unMapped.bed
liftOver -bedPlus=3 -minMatch=$4 "$FILEID"_res.bed $3 swapped_res unMapped

sort-bed $1 > "$FILEID"_sorted.bed
sort-bed swapped_res  > swapped_sorted
bedmap --echo --echo-map-id-uniq --delim '\t' --fraction-ref 0.5 "$FILEID"_sorted.bed swapped_sorted \
	| awk '{split($5, ids, ";")}; { for(n in ids) if (ids[n] == $4) print $4}' > ids

rm "$FILEID"_sorted.bed swapped_res unMapped swapped_sorted

fgrep -wf ids "$FILEID"_res.bed > "$FILEID"_recip_liftOver_res.bed

rm ids




