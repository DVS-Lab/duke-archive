#!/bin/bash

for MODEL in "faces" "money"; do

	if [ "$MODEL" == "faces" ]; then
		for LIST in "all 1" "4star 2" "3star 3" "2star 4" "1star 5" "4star-1star 6" "1star-4star 7" "hot-not 8" "not-hot 9" "4s-3s 10" "3s-4s 11" "2s-1s 12" "1s-2s 13"; do
	
			set -- $LIST 
			CON_NAME=$1
			COPENUM=$2
				
			qsub -v EXPERIMENT=SocReward.01 L3_1cope.sh ${CON_NAME} ${COPENUM} ${MODEL}

			qstat > waiting.txt
			NUM=`grep -c "qw" waiting.txt`
			while [ $NUM -gt 5 ]; do 
				sleep 10
				qstat > waiting.txt
				NUM=`grep -c "qw" waiting.txt`
			done
		done
	else

		for LIST in "all 1" "gain5 2" "gain2 3" "gain1 4" "loss5 5" "loss2 6" "loss1 7" "gain-loss 8" "loss-gain 9" "5gain-5loss 10" "5loss-5gain 11" "5+2gain-5+2loss 12" "5+2loss-5+2gain 13" "5-1 14" "5-2 15" "5&2-1 16" "5-1&2 17"; do
	
			set -- $LIST 
			CON_NAME=$1
			COPENUM=$2
				
			qsub -v EXPERIMENT=SocReward.01 L3_1cope.sh ${CON_NAME} ${COPENUM} ${MODEL}
					
			qstat > waiting.txt
			NUM=`grep -c "qw" waiting.txt`
			while [ $NUM -gt 5 ]; do 
				sleep 10
				qstat > waiting.txt
				NUM=`grep -c "qw" waiting.txt`
			done
		done
	fi
done
rm waiting.txt


