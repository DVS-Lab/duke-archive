#!/bin/sh

for CLASS in "RbfNuSVMC" "LinearNuSVMC" "SMLR"; do
	for MASK in "new" "old"; do 
		for TEST in "neglect" "size"; do
			qsub -l h_vmem=3G -v EXPERIMENT=Imagene.02 MVPA_WB.sh $MASK $TEST $CLASS
			sleep 5s
		done
	done
done
# MASK=$1
# TESTNAME=$2
# DATATYPE=$3
# CLASSIFIER=$4
