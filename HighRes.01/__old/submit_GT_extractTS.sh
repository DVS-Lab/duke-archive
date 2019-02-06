#!/bin/sh

for F in 0; do
	for SO in 1; do
		for SUBJ in 1000 1001 1002 1003 1004 1005 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019; do
			for S in 2; do
				for R in 1 2 3 4 5; do
					qsub -v EXPERIMENT=HighRes.01 GT_extractTS.sh $SUBJ $S $F $SO $R
					sleep 2s
				done
			done
		done
	done
done
