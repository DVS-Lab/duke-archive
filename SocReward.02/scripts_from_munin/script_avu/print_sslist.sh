#!/bin/sh
LIST=$1
echo $LIST

echo " "
echo " "
echo " "

cat $LIST | 
while read a; do
	FILENAME=/mnt/BIAC/.users/avu4/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis/avu/Social_nonsoc_anticip_lvl2/${a}_L2.gfeat/cope7.feat/stats/cope1.nii.gz
	echo $FILENAME
done

#echo " "
#echo " "
#echo " "
#
#LIST=$1
#cat $LIST | 
#while read a; do
#	FILENAME=/mnt/BIAC/.users/avu4/munin.dhe.duke.edu/Huettel/Imagene.02/Analysis/TaskData/${a}/${a}_anat_brain.nii.gz
#	echo $FILENAME
#done

