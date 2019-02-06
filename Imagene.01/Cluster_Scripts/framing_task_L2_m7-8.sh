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
# #$ -M smith@biac.duke.edu
# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


FSLDIR=/usr/local/fsl-4.1.4-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh


SUBJ=SUB_SUBNUM_SUB
GO=SUB_GO_SUB
MODEL=SUB_MODEL_SUB

#data location and other variables
OUTPUT=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/${SUBJ}_model${MODEL}
FEAT1=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run1/${SUBJ}_model${MODEL}_run1.feat
FEAT2=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run2/${SUBJ}_model${MODEL}_run2.feat
FEAT3=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run3/${SUBJ}_model${MODEL}_run3.feat
OUTDIR=$EXPERIMENT/Analysis/Framing/Logs/DVS/L2_m${MODEL}
mkdir -p $OUTDIR

# OUTPUT=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/${SUBJ}_model${MODEL}_badTRs
# FEAT1=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run1/${SUBJ}_model${MODEL}_badTRs_run1.feat
# FEAT2=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run2/${SUBJ}_model${MODEL}_badTRs_run2.feat
# FEAT3=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run3/${SUBJ}_model${MODEL}_badTRs_run3.feat


if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.gfeat
fi

NCOPES=18
if [ -d $OUTPUT.gfeat ]; then
	cd $OUTPUT.gfeat
	for C in `seq $NCOPES`; do
		CHECK_FILE=$OUTPUT.gfeat/cope${C}.feat/cluster_mask_zstat1.nii.gz
		if [ -e $CHECK_FILE ]; then
			COPE1_GOOD=1
		else
			COPE1_GOOD=0
			cd $EXPERIMENT
			rm -rf $OUTPUT.gfeat
		fi
	done
fi


TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_m7-8.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@FEAT1@'$FEAT1'@g' \
-e 's@FEAT2@'$FEAT2'@g' \
-e 's@FEAT3@'$FEAT3'@g' \
<$TEMPLATE> ${OUTPUT}.fsf

#run the newly created fsf files
if [ -d $OUTPUT.gfeat ]; then
	echo "$OUTPUT.gfeat exists! skipping to the next one"
else
	$FSLDIR/bin/feat ${OUTPUT}.fsf
fi

for COPE in `seq $NCOPES`; do
	cd ${OUTPUT}.gfeat
	cd cope${COPE}.feat
	rm -f filtered_func_data.nii.gz
	rm -f var_filtered_func_data.nii.gz
	rm -f stats/res4d.nii.gz 
done


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
