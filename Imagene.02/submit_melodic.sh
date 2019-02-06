#!/bin/bash

for D in `seq 3 15`; do
	qsub -l h_vmem=36G -v EXPERIMENT=Imagene.02 melodic.sh $D
	sleep 10s
done

