#!/bin/bash

for i in `cat resting_list2.txt`; do
	qsub -v EXPERIMENT=Imagene.02 RestingPPI_YesIKnow.sh $i
	sleep 10s
done
