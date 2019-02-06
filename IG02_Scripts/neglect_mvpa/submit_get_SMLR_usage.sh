#!/bin/sh


# MASK=$1
# COMBOS=$2
# TEST=$3
# CLASS=$4
# DATA=$5
COMBOS=2
for MASK in "new" "old"; do 
	for TEST in "neglect" "size"; do
		for CLASS in "SMLR" "SMLR2" "SMLR3"; do
			for DATA in "raw" "normed"; do
				qsub -l h_vmem=2G -v EXPERIMENT=Imagene.02 get_SMLR_usage.sh $MASK $COMBOS $TEST $CLASS $DATA
				sleep 5s
			done
		done
	done
done

# MASK=$1
# ROI=$2
# NCOMBO=$3
