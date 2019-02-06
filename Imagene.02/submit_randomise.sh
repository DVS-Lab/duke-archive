#!/bin/bash

for d in 3 5 7; do
	if [ $d -eq 3 ]; then NCOPES=9; fi
	if [ $d -eq 5 ]; then NCOPES=25; fi
	if [ $d -eq 7 ]; then NCOPES=49; fi
	echo $NCOPES
	for L in 1 2; do
		for C in `seq $NCOPES`; do
			qsub -v EXPERIMENT=Imagene.02 randomise.sh $C $L $d
			sleep 7s
		done
	done
done
