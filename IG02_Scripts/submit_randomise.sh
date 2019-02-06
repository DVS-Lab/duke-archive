#!/bin/bash

# EXP=$1
# CON=$2
# DES=$3 #design_linquad

for EXP in IG01 IG02; do
	for CON in 11 12 13 14 19 20; do
		#for DES in design design_linquad; do
		for DES in design; do
			qsub -v EXPERIMENT=Imagene.02 randomise.sh $EXP $CON $DES
			sleep 5s
		done
	done
done

