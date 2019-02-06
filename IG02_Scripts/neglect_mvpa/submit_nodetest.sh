#!/bin/sh

for N in `seq 3 60`; do 

	qsub -l h_vmem=1G -l hostname=node${N} -v EXPERIMENT=Imagene.02 nodetest.sh
	sleep 5s

done

# MASK=$1
# ROI=$2
# NCOMBO=$3
