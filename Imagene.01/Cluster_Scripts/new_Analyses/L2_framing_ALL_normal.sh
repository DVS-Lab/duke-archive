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

# 
# FSLDIR=/usr/local/fsl-4.1.4-centos4_64
# export FSLDIR
# source $FSLDIR/etc/fslconf/fsl.sh


SUBJ=SUB_SUBNUM_SUB
GO=SUB_GO_SUB
MODEL=SUB_MODEL_SUB

#data location and other variables
OUTPUT=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/corrected_NoLapses/model${MODEL}
#file:///Volumes/Huettel/Imagene.01/Analysis/Framing/FSL/47725/corrected_NoLapses/model11/run2.feat/report_stats.html

OUTDIR=$EXPERIMENT/Analysis/Framing/Logs/DVS/L2_m${MODEL}_new
mkdir -p $OUTDIR

# OUTPUT=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/${SUBJ}_model${MODEL}_badTRs
# FEAT1=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run1/${SUBJ}_model${MODEL}_badTRs_run1.feat
# FEAT2=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run2/${SUBJ}_model${MODEL}_badTRs_run2.feat
# FEAT3=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run3/${SUBJ}_model${MODEL}_badTRs_run3.feat


if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.gfeat
fi

NCOPES=13
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

# 47921	Framing	2
# 48150	Framing	1
# 48152	Framing	2
# 48172	Framing	3
# 48206	Framing	2
# 48326	Framing	1

# 47729	1
# 47731	3
# 47921	2
# 48012	1
# 48123	1
# 48150	1
# 48152	2
# 48165	2
# 48167	2
# 48204	3
# 48206	2
# 48271	3
# 48281	3
# 48349	3

# 1s
# 47729
# 48012
# 48123
# 48150
# 
# 2s
# 47921
# 48152
# 48165
# 48167
# 48206
# 
# 3s
# 47731
# 48349
# 48281
# 48271
if [ $SUBJ -eq 47731 ] || [ $SUBJ -eq 48349 ] || [ $SUBJ -eq 48281 ] || [ $SUBJ -eq 48271 ]; then
	FEAT1=${OUTPUT}/run1.feat
	FEAT2=${OUTPUT}/run2.feat
	TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_13copes_2runs.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@FEAT1@'$FEAT1'@g' \
	-e 's@FEAT2@'$FEAT2'@g' \
	<$TEMPLATE> ${OUTPUT}.fsf


elif [ $SUBJ -eq 47921 ] || [ $SUBJ -eq 48152 ] || [ $SUBJ -eq 48165 ] || [ $SUBJ -eq 48167 ] || [ $SUBJ -eq 48206 ]; then
	FEAT1=${OUTPUT}/run1.feat
	FEAT2=${OUTPUT}/run3.feat
	TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_13copes_2runs.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@FEAT1@'$FEAT1'@g' \
	-e 's@FEAT2@'$FEAT2'@g' \
	<$TEMPLATE> ${OUTPUT}.fsf

elif [ $SUBJ -eq 47729 ] || [ $SUBJ -eq 48012 ] || [ $SUBJ -eq 48123 ] || [ $SUBJ -eq 48150 ]; then
	FEAT1=${OUTPUT}/run2.feat
	FEAT2=${OUTPUT}/run3.feat
	TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_13copes_2runs.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@FEAT1@'$FEAT1'@g' \
	-e 's@FEAT2@'$FEAT2'@g' \
	<$TEMPLATE> ${OUTPUT}.fsf
else
	FEAT1=${OUTPUT}/run1.feat
	FEAT2=${OUTPUT}/run2.feat
	FEAT3=${OUTPUT}/run3.feat
	TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_13copes_3runs.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@FEAT1@'$FEAT1'@g' \
	-e 's@FEAT2@'$FEAT2'@g' \
	-e 's@FEAT3@'$FEAT3'@g' \
	<$TEMPLATE> ${OUTPUT}.fsf

fi

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
