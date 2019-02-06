#!/bin/sh

for F in 0 1; do
	for ROI in "FFA" "PPA"; do
		for SUBJ in 1002 1005 1006 1007 1008 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022; do
			for S in 2; do
				qsub -v EXPERIMENT=HighRes.01 m4_L2_analysis.sh $SUBJ $S $F $ROI
				sleep 5s
			done
		done
	done
done
#no L2 for 1009 or 1023