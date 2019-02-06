#!/bin/sh

# This is a BIAC template script for jobs on the cluster
# You have to provide the Experiment on command line  
# when you submit the job the cluster.
#
# >  qsub -v EXPERIMENT=Dummy.01  script.sh args
#
# There are 2 USER sections 
#  1. USER DIRECTIVE: If you want mail notifications when
#     your job is completed or fails you need to set the 
#     correct email address.
#		   
#  2. USER SCRIPT: Add the user script in this section.
#     Within this section you can access your experiment 
#     folder using $EXPERIMENT. All paths are relative to this variable
#     eg: $EXPERIMENT/Data $EXPERIMENT/Analysis	
#     By default all terminal output is routed to the " Analysis "
#     folder under the Experiment directory i.e. $EXPERIMENT/Analysis
#     To change this path, set the OUTDIR variable in this section
#     to another location under your experiment folder
#     eg: OUTDIR=$EXPERIMENT/Analysis/GridOut 	
#     By default on successful completion the job will return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return 
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110
#     Arguments to the USER SCRIPT are accessible in the usual fashion
#     eg:  $1 $2 $3
# The remaining sections are setup related and don't require
# modifications for most scripts. They are critical for access
# to your data  	 

# --- BEGIN GLOBAL DIRECTIVE -- 
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
# #$ -m ea
# -- END GLOBAL DIRECTIVE -- 

# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access 
EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}

source /etc/biac_sge.sh

EXPERIMENT=`biacmount $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}

if [ $EXPERIMENT = "ERROR" ]
then
	exit 32
else 
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----" 
# -- END PRE-USER --
# **********************************************************

# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
# #$ -M david.v.smith@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

MAINDIR=${EXPERIMENT}/Analysis/HighRes_GT/forCNS_LesionMVPA
cd $MAINDIR

MASK=$1
COMBOS=$2
TEST=$3
CLASS=$4
DATA=$5

#ATLAS=$3

if [ $MASK == "new" ]; then
	ROIDIR=ROIs_newmask
elif [ $MASK == "old" ]; then
	ROIDIR=ROIs_oldmask
else
	echo "if statement fail...."
fi

OUTPUTFILE=${MAINDIR}/PyMVPA_DVS/Analysis/ROIs/usage_${TEST}_combo${COMBOS}_${CLASS}_${MASK}_${DATA}data.txt
#/PyMVPA_DVS/Data/ROIs_oldmask/combo2/ROIcombo_002_004.nii.gz
#/PyMVPA_DVS/Analysis/ROIs/SMLR2/sens_maps/old/2/raw/neglect/neglect_sensmap_down_SMLR2_old_002_004_rawdata.nii.gz
if [ $COMBOS -eq 2 ]; then
	FILENAME=${MAINDIR}/anatROIs_c2_wJuelich_${MASK}mask.txt

	cat $FILENAME | 
	while read a; do 
	set -- $a
		
		MASKFILE=${MAINDIR}/PyMVPA_DVS/Data/ROIs_${MASK}mask/combo${COMBOS}/ROIcombo_${1}_${2}.nii.gz
		MAPFILE=${MAINDIR}/PyMVPA_DVS/Analysis/ROIs/${CLASS}/sens_maps/${MASK}/${COMBOS}/${DATA}/${TEST}/${TEST}_sensmap_down_${CLASS}_${MASK}_${1}_${2}_${DATA}data.nii.gz
		
		MASK_SIZE=`fslstats $MASKFILE -V | awk '{print $1}'`
		MAP_SIZE=`fslstats $MAPFILE -V | awk '{print $1}'`
		
		PCT_USED=`bc -l <<< "${MAP_SIZE} / ${MASK_SIZE}"`
		echo $PCT_USED >> $OUTPUTFILE
	done
fi

OUTDIR=$MAINDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
#rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
