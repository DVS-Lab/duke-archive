#!/bin/sh

COUNTER=0
for LIST in "face-money 1" "money-face 2" "hot-not 3" "hot-neutralf 4" "gain-loss 5" "gain-neutralm 6" "pos-neg 7" "not-hot 8" "not-neutralf 9" "loss-gain 10" \
"loss-neutralm 11" "neg-pos 12" "neutralf-hot 13" "neutralf-not 14" "neutralm-gain 15" "neutralm-loss 16" "hot 17" "neutralf 18" "not 19" "gain 20" "neutral 21" "loss 22"; do


	set -- $LIST #parses list
	CON_NAME=$1
	COPENUM=$2


	qsub -v EXPERIMENT=SocReward.01 third_1cope_averse.sh ${CON_NAME} ${COPENUM}
	let "COUNTER=$COUNTER+1"
	if [ $COUNTER -eq 100 ]; then		
	echo "sleeping for 25 minutes at `date`. loop $LOOP"
	sleep 1500
	COUNTER=0
	fi	
	
done



