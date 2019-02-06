#!/bin/bash


SUBJ=$1
MODEL=$2

if [ $COPENUM -eq 1 ]; then
	NAME=social
else
	NAME=money
fi

#Y:\Huettel\SocReward.01\Analysis\Cluster\PassiveTask\33402\L2_Paired_Tests\4star-1star_MINUS_5+2gain-5+2loss.gfeat\cope1.feat
EXPERIMENT=/home/smith/experiments/SocReward.01
MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask
MODELDIR=${MAINDIR}/${SUBJ}/L2_Paired_Tests/${MODEL}.gfeat
echo $MODELDIR

COPE=${MODELDIR}/cope1.feat
MASKDIR=${MAINDIR}/ROIs_functional
MASKNAME=paired_mOFC_mask
MASK=${MAINDIR}/ROIs_functional/paired_mOFC_mask.nii.gz

featquery 1 ${COPE} 1  stats/cope1 ${MASKNAME}_featquery_${NAME} -p ${MASK} 
#this will return percent signal change. type featquery into the command terminal for additional options.

