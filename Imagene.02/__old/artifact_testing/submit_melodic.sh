#!/bin/bash



SUBJ_FULL=20100701_11100
#/20100412_10693/run004_02/run004_02.ica/filtered_func_data.ica/report/IC_2.html
for LIST in "run003_02 1.58" "run003_03 1.58"; do
	set -- $LIST
	RUN=$1
	SET_TR=$2

	qsub -v EXPERIMENT=Imagene.02 melodic.sh ${RUN} ${SET_TR} ${SUBJ_FULL}
	sleep 2s
done


SUBJ_FULL=20100701_11102
#/20100412_10693/run004_02/run004_02.ica/filtered_func_data.ica/report/IC_2.html
for LIST in "run003_02 1.58"; do
	set -- $LIST
	RUN=$1
	SET_TR=$2

	qsub -v EXPERIMENT=Imagene.02 melodic.sh ${RUN} ${SET_TR} ${SUBJ_FULL}
	sleep 2s
done
