#!/bin/bash


for SUBJ in 13282 13298 13323 13329 13346 13367 13383 13392 13431 13483 13527 13534 13540 13551 13559 13637 13647 13654 13696 13849 13863 13875 13886 13928 13944 13952; do
	
	qsub -v EXPERIMENT=SocReward.02 run5_prestats.sh ${SUBJ}
	sleep 8s

done

