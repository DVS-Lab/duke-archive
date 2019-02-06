#!/bin/sh

#for GICA in groupmelodic_10dim_firsthalf_noSmooth_thr10_spline groupmelodic_10dim_secondhalf_noSmooth_thr10_spline; do
for GICA in groupmelodic_10dim_firsthalf_noSmooth_thr10_spline; do
	for ICNAM in VTA_minus_SN SN_minus_VTA; do
		if [ "$GICA" == "groupmelodic_10dim_firsthalf_noSmooth_thr10_spline" ]; then
			DR=DR_output_ttest_n69_corrected
		else
			DR=DR_output_ttest_n70_corrected
		fi
		echo $DR
		qsub -v EXPERIMENT=Imagene.02 DR_randomise_SNvsVTA.sh $GICA $DR $ICNAM
		sleep 5

	done
done