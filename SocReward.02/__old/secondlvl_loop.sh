#!/bin/sh

for SUBJ in 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33135 33402 33456 33642 33669 33746 33754 33757 33771 33784 33467 33744; do

#for SUBJ in 32953 32958 32976 32984 33035 33045 33064 33082 33135 33288 33402 33456 33642 33669 33746 33754 33757 33771 33784; do
	qsub -v EXPERIMENT=SocReward.01 secondlvl_feat.sh ${SUBJ}
	

done



