#!/bin/sh

for N in `seq 1 250`; do 

	qsub -l h_vmem=1G -v EXPERIMENT=Imagene.02 test.sh
	#sleep 1s

done

# MASK=$1
# ROI=$2
# NCOMBO=$3
