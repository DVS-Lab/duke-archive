#!/bin/sh

#echo "sleeping for 1 hour at `date`"
#sleep 1h

#for LIST in "gica_RestOnly_split1_striatum rest_split1" "gica_TaskOnly_split1_striatum mid_split1" "gica_RestOnly_split2_striatum rest_split2" "gica_TaskOnly_split2_striatum mid_split2" "gica_TaskRest_split2_striatum mid-rest_split2" "gica_TaskRest_split1_striatum mid-rest_split1"; do

for DR in DR_wb_corrected_Task_Xsplit DR_wb_corrected_Rest2Task; do
	for LIST in "gica_TaskOnly_split1_striatum_smoothed mid_split1" "gica_TaskOnly_split2_striatum_smoothed mid_split2" "gica_TaskOnly_split1_striatum mid_split1" "gica_TaskOnly_split2_striatum mid_split2"; do
		set -- $LIST
		GICA=$1
		MODEL=$2
		for ICNUM in `seq 0 9`; do
			echo $DR $MODEL $GICA
			qsub -v EXPERIMENT=Imagene.02 DR_randomise.sh $GICA $DR $ICNUM $MODEL
			sleep 2
		done
	done
done

DR=DR_wb_corrected
for ISSMOOTHED in 1 0; do
	for LIST in "gica_RestOnly_split1_striatum rest_split1" "gica_TaskOnly_split1_striatum mid_split1" "gica_RestOnly_split2_striatum rest_split2" "gica_TaskOnly_split2_striatum mid_split2" "gica_TaskRest_split2_striatum mid-rest_split2" "gica_TaskRest_split1_striatum mid-rest_split1"; do

		set -- $LIST
		if [ $ISSMOOTHED -eq 1 ]; then
			GICA=${1}_smoothed
		else
			GICA=${1}
		fi
		MODEL=$2
		for ICNUM in `seq 0 9`; do
			echo $DR $MODEL $GICA
			qsub -v EXPERIMENT=Imagene.02 DR_randomise.sh $GICA $DR $ICNUM $MODEL
			sleep 2
		done
	done
done
