#!/bin/sh

for CLASS in "RbfNuSVMC" "LinearNuSVMC"; do
	for OUTBASE in "1D" "2D"; do
		for ROI in "001_001_001" "053_016_032" "074_047_044" "052_026_032" "081_056_040"; do
			qsub -l h_vmem=3G -v EXPERIMENT=Imagene.02 vox_redos.sh $CLASS $OUTBASE $ROI
			sleep 5s
		done
	done
done

