#!/bin/bash

for D in "04" "07" "10" "13" "16"; do
	qsub -l h_vmem=8G -v EXPERIMENT=Imagene.02 DR2.sh $D 1
	sleep 10s
	qsub -l h_vmem=8G -v EXPERIMENT=Imagene.02 DR2.sh $D 2
	sleep 10s
done
