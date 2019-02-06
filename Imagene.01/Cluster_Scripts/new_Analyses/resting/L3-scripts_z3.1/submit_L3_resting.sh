#!/bin/bash

for LIST in "global_pos 1" "global_neg 2" "local_pos 3" "local_neg 4"; do

	set -- $LIST
	CNAME=$1
	CNUM=$2
	
	for ROI in "PCC1" "PCC2" "PCC3"; do
	
		qsub -v EXPERIMENT=Imagene.01 L3_forFraming_n41.sh $CNUM $CNAME $ROI
		sleep 2s
		qsub -v EXPERIMENT=Imagene.01 L3_forMID_n43.sh $CNUM $CNAME $ROI
		sleep 2s
	done
done

