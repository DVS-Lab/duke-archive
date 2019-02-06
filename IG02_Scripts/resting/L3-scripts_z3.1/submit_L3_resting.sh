#!/bin/bash

for LIST in "global_pos 1" "global_neg 2" "local_pos 3" "local_neg 4"; do

	set -- $LIST
	CNAME=$1
	CNUM=$2
	
	#for FILTER in "ICAnormal" "ICAspecial" "lpfilt"; do
	for FILTER in "ICAspecial"; do
		qsub -v EXPERIMENT=Imagene.02 L3_resting_n67.sh $CNUM $CNAME $FILTER
		sleep 2s
		#qsub -v EXPERIMENT=Imagene.01 L3_forMID_n43.sh $CNUM $CNAME $ROI
		#sleep 2s
	done
done

