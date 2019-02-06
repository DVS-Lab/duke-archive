#!/bin/bash


SUBJECTS=( 20110718_13282 , 20110720_13298)


LENGTH=${#SUBJECTS[@]}
let LENGTH=$LENGTH-1

N=0
for x in `seq 0 $LENGTH`; do
	
	let N=$N+1
	SUBJ_FULL=${SUBJECTS[$x]}
	SUBJ=${SUBJ_FULL:9}

	qsub -v EXPERIMENT=SocReward.02 initialconvert.sh ${SUBJ_FULL} ${SUBJ}
	sleep 8s
done

