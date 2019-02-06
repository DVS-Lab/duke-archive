#!/bin/sh

for N in `seq 3 17`; do 

	qsub -l h_vmem=2G -l hostname=node${N} -v EXPERIMENT=Imagene.02 clusterfail.sh $N
	sleep 5s

done
# MASK=$1
# ROI=$2
# NCOMBO=$3
