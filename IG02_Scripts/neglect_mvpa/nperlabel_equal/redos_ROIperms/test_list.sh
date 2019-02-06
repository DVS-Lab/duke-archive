#!/bin/sh
LIST=genderall_sslist.txt
cat $LIST | 
while read a; do
	FILENAME=/mnt/BIAC/.users/avu4/munin.dhe.duke.edu/Huettel/Imagene.02/Analysis/TaskData/${a}/Resting/MELODIC_150/Smooth_6mm/run1.ica/unconfounded_data.nii.gz
	echo $a
done