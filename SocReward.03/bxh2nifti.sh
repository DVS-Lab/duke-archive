#!/bin/bash
# 
# SUBJ_FULL=$1
# SUBJ=$2
# NUMRUNS=$3
# PASSIVE=$4
# PASSIVE_CUED=$5
# ACTIVE=$6
# REST=$7
# ANAT_SERIES=$8
# 



for LIST in "20081006_35009 35009" "20081008_35025 35025" "20081021_35086 35086" "20081119_35267 35267" "20081121_35280 35280" "20081121_35283 35283"; do
	
	set -- $LIST
	SUBJ_FULL=$1
	SUBJ=$2

	if [ $SUBJ -eq 35086 ]; then
		qsub -v EXPERIMENT=SocReward.03 bxh2analyze_orient2_special.sh $SUBJ_FULL $SUBJ 6 1 4 5 "0 0" series300
	else
		qsub -v EXPERIMENT=SocReward.03 bxh2analyze_orient2.sh $SUBJ_FULL $SUBJ 7 1 4 6 "0 0" series300
	fi

done