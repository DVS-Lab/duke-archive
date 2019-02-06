#!/bin/sh

for OPT in 2 3; do
	for C in "LinearNuSVMC"; do
		qsub -v EXPERIMENT=Imagene.02 delete_junk.sh $OPT $C
		sleep 5s
	done
done
