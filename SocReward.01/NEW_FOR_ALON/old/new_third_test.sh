#!/bin/sh


for LIST in "face-money 1" "money-face 2" "hot-not 3" "hot-neutralf 4" "gain-loss 5" "gain-neutralm 6" "pos-neg 7" "not-hot 8" "not-neutralf 9" "loss-gain 10" "loss-neutralm 11" "neg-pos 12" "neutralf-hot 13" "neutralf-not 14" "neutralm-gain 15" "neutralm-loss 16"; do

	set -- $LIST #parses list
	CON_NAME=$1
	COPENUM=$2


	qsub -v EXPERIMENT=SocReward.01 new_1cope_test.sh ${CON_NAME} ${COPENUM}
	

done



