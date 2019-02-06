#!/bin/sh

for SUBJ in 1002 1005 1006 1007 1008 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022; do
	qsub -v EXPERIMENT=HighRes.01 m4_L2_analysis.sh $SUBJ 0 1 1
	sleep 10s
done
# no L2 for 1009 or 1023
# -l h_vmem=12G