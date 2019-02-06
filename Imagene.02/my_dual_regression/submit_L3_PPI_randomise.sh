#!/bin/sh




for SPLIT in 1 2; do
	for COPENUM in 1 2 3 4 5 6 7 8 9; do
		qsub -v EXPERIMENT=Imagene.02 L3_PPI_randomise.sh $SPLIT $COPENUM
		sleep 1s
	done
done

