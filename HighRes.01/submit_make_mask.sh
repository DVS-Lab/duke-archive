#!/bin/sh

for F in 1; do
	for SUBJ in 1002 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023; do
		for R in 1 2 3 4 5; do
			qsub -v EXPERIMENT=HighRes.01 make_mask.sh $SUBJ $F $R
			sleep 5s
		done
	done
done
