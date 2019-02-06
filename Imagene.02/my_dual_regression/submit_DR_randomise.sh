#!/bin/sh

#for GICA in groupmelodic_10dim_firsthalf_noSmooth_thr10_spline groupmelodic_10dim_secondhalf_noSmooth_thr10_spline; do

for GICA in groupmelodic_10dim_firsthalf_noSmooth_thr10_spline; do
	for ICNUM in `seq 0 9`; do
		if [ "$GICA" == "groupmelodic_10dim_firsthalf_noSmooth_thr10_spline" ]; then
			DR=DR_output_ttest_n69_corrected
		else
			DR=DR_output_ttest_n70_corrected
		fi
		echo $DR
		qsub -v EXPERIMENT=Imagene.02 DR_randomise.sh $GICA $DR $ICNUM
		sleep 5

	done
done