#!/bin/bash


#--data type shifted to int16 (short) and scaling factor (only on funcs?) reduced from 1000 to 500 (2/22/10)
#--changed time points starting on 10279. IRG cut to two runs. 

#subject list from first pass analysis (3/13/10)--only includes those prior to 2/22/10
SUBJECTS=( 20091208_10156 20091210_10168 20091214_10181 20091218_10199 20100119_10255 20100119_10256 20100120_10264 20100120_10265 20100126_10279 20100126_10280 20100126_10281 20100127_10286 20100127_10287 20100128_10294 20100202_10303 20100202_10304 20100202_10305 20100202_10306 20100203_10314 20100203_10315 20100212_10335 20100216_10350 20100216_10351 20100216_10352 20100217_10358 20100217_10359 20100217_10360 )

#SUBJECTS=( 20100120_10264 20100120_10265 ) #had to re-do these two subjects because of a bug in my script (i accidentally skipped run2 of Risk)


LENGTH=${#SUBJECTS[@]}
let LENGTH=$LENGTH-1

N=0
for x in `seq 0 $LENGTH`; do
	
	let N=$N+1
	SUBJ_FULL=${SUBJECTS[$x]}
	SUBJ=${SUBJ_FULL:9}
	
	for TASK in MID Framing Risk Resting; do
		if [ "$TASK" == "Resting" ]; then
			RUNS=1
		else
			RUNS=3
		fi

		for RUN in `seq $RUNS`; do
			qsub -v EXPERIMENT=Imagene.02 FIX_datatype+scaling.sh ${SUBJ} ${RUN} ${TASK}
			sleep 5s
		done
	done
done

