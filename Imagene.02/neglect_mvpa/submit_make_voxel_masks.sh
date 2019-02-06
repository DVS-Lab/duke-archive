#!/bin/sh

for X in `seq 1 91`; do 

	qsub -v EXPERIMENT=Imagene.02 make_voxel_masks.sh $X
	sleep 5s

done

# MASK=$1
# ROI=$2
# NCOMBO=$3
