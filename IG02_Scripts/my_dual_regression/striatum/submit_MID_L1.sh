#!/bin/sh

for SPLIT in 1 2; do
	for SUBJ in `cat split${SPLIT}_sorted.txt`; do
		qsub -v EXPERIMENT=Imagene.02 MID_L1.sh $SUBJ
		sleep 5s
	done
done

