#!/bin/bash

for LIST in "global_pos 1" "global_neg 2" "local_pos 3" "local_neg 4"; do

	set -- $LIST
	CNAME=$1
	CNUM=$2
	
	for ROI in "PCC1" "PCC2" "PCC3"; do
	
		qsub -v EXPERIMENT=Imagene.01 L3_m7_n51.sh $CNUM $CNAME $ROI
		qsub -v EXPERIMENT=Imagene.01 L3_m7_n50.sh $CNUM $CNAME $ROI

	done
done

