#!/bin/sh

for combo in 3; do
	for rep in 1 2 3 4 5; do
		for data in "normed" "raw"; do
			qsub -v EXPERIMENT=Imagene.02 MVPA_ROI_perm_redo_RBF.sh $rep $data $combo
			sleep 5
		done
	done
done
