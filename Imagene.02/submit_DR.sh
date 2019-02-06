#!/bin/bash

for D in "05" "10" "15" "20"; do
	qsub -l h_vmem=8G -v EXPERIMENT=Imagene.02 DR.sh $D 1
	sleep 10s
	qsub -l h_vmem=8G -v EXPERIMENT=Imagene.02 DR.sh $D 2
	sleep 10s
done
