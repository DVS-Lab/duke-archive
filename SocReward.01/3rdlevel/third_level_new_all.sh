#!/bin/sh



for MODEL in "4star-1star_MINUS_5+2gain-5+2loss" "4star-1star_MINUS_5gain-5loss" "4star-1star_MINUS_gain-loss" "hot-not_MINUS_5+2gain-5+2loss" "hot-not_MINUS_5gain-5loss" "hot-not_MINUS_gain-loss"; do
	
	for LIST in "social 1" "money 2" "social-money 3" "money-social 4"; do
		set -- $LIST 
		CON_NAME=$1
		COPENUM=$2
			
		qsub -v EXPERIMENT=SocReward.01 L3_1cope.sh ${CON_NAME} ${COPENUM} ${MODEL}
		#echo "qsub -v EXPERIMENT=SocReward.01 L3_1cope.sh ${CON_NAME} ${COPENUM} ${MODEL}"
	done
done
