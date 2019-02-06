#!/bin/sh


#for RUN_JOBS in 1 2; do 

	for SMOOTH in 6; do
  
		for AUTOVERSION in "0.7.1"; do
		
			for OPTION in "crap"; do	

				for LIST in "face-money 1" "money-face 2" "hot-not 3" "hot-neutralf 4" "gain-loss 5" "gain-neutralm 6" "pos-neg 7" "not-hot 8" "not-neutralf 9" "loss-gain 10" \
				"loss-neutralm 11" "neg-pos 12" "neutralf-hot 13" "neutralf-not 14" "neutralm-gain 15" "neutralm-loss 16" "hot 17" "neutralf 18" "not 19" "gain 20" "neutral 21" "loss 22"; do
				
				#for LIST in "1star 1" "2star 2" "3star 3" "4star 4" "gain1 5" "gain2 6" "gain5 7" "loss1 8" "loss2 9" "loss5 10" "face 11" "money 12" "face-money 13" "money-face 14" "1star-4star 15" \
				#"4star-1star 16" "not-hot 17" "hot-not 18" "gain-loss 19" "loss-gain 20" "pos-neg 21" "neg-pos 22" "pos 23" "neg 24" "gain 25" "loss 26" "hot 27" "not 28"; do

				set -- $LIST 
				CON_NAME=$1
				COPENUM=$2
					
				qsub -v EXPERIMENT=SocReward.01 third_level_new_1cope.sh ${CON_NAME} ${COPENUM} ${SMOOTH} ${AUTOVERSION} ${OPTION}
						
				done
				
			done
			
		done
		
	done
	
#done



