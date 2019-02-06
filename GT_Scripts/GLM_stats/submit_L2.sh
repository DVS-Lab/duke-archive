#!/bin/sh

for F in 0 1; do
	for SO in 1; do
		for SUBJ in 1002 1005 1006 1007 1008 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022; do
			for S in 0 2; do
				qsub -v EXPERIMENT=HighRes.01 L2_m3_highres.sh $SUBJ $S $F $SO
				sleep 5s
			done
		done
	done
done
#no L2 for 1009 or 1023