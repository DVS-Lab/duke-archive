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

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here
#SUB_USEREMAIL_SUB

SUBJ=SUB_SUBNUM_VAR
RUN=SUB_RUN_VAR
SMOOTH=SUB_SMOOTH_VAR
GO=SUB_GO_VAR

FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh

MAINDIR=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/PreStatsOnly2/${SUBJ}_prestats_Smooth_${SMOOTH}mm
OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
ROIDIR=${MAINDIR}/ROIs_NEW/AAL_4x4x4

OUTPUTDIR1=${MAINOUTPUT}/ROI_data/masks_native/run${RUN}
OUTPUTDIR2=${MAINOUTPUT}/ROI_data/data_native/run${RUN}
OUTPUTDIR3=${MAINOUTPUT}/ROI_data/masks_std/run${RUN}
OUTPUTDIR4=${MAINOUTPUT}/ROI_data/data_std/run${RUN}
OUTPUTDIR5=${MAINOUTPUT}/ROI_data/data_native/matfiles/run${RUN}
OUTPUTDIR6=${MAINOUTPUT}/ROI_data/data_std/matfiles/run${RUN}

mkdir -p $OUTPUTDIR1
mkdir -p $OUTPUTDIR2
mkdir -p $OUTPUTDIR3
mkdir -p $OUTPUTDIR4
mkdir -p $OUTPUTDIR5
mkdir -p $OUTPUTDIR6

#create masked data for proper registrations
F_VALUE=0.55
cd $OUTPUTREAL
rm new_mask.nii
DATA=${MAINOUTPUT}/run${RUN}.feat/filtered_func_data.nii.gz
MATRIX=${MAINOUTPUT}/run${RUN}.feat/reg/example_func2standard.mat
REF=${MAINOUTPUT}/run${RUN}.feat/reg/standard.nii.gz
DATA2=${MAINOUTPUT}/run${RUN}.feat/new_filtered_func_data.nii.gz
NEWDATA=${MAINOUTPUT}/run${RUN}.feat/data_func2mni_new
NEWDATA2=${MAINOUTPUT}/run${RUN}.feat/data_func2mni_new2


cd ${MAINOUTPUT}/run${RUN}.feat
rm -rf *.nii

 BETINPUT=mean_func.nii.gz
 BETOUTPUT=new
 BETCMD="bet $BETINPUT $BETOUTPUT -f ${F_VALUE} -m"
 eval $BETCMD
 rm -f new.nii.gz 
 fslmaths filtered_func_data.nii.gz -mas new_mask.nii.gz new_filtered_func_data
#  flirt -in ${DATA2} -ref ${REF} -applyisoxfm 4 -init ${MATRIX} -out ${NEWDATA}
#  flirt -in ${DATA} -ref ${REF} -applyisoxfm 4 -init ${MATRIX} -out ${NEWDATA2}

flirt -in ${DATA2} -ref ${REF} -applyxfm -init ${MATRIX} -out ${NEWDATA}
# flirt -in ${DATA} -ref ${REF} -applyxfm -init ${MATRIX} -out ${NEWDATA2}

cd $ROIDIR
for F in *.nii.gz; do

	MASKNAME=${F}
	MASK=${ROIDIR}/${MASKNAME}

	#to native
	REF=${MAINOUTPUT}/run${RUN}.feat/reg/example_func.nii.gz
	MATRIX=${MAINOUTPUT}/run${RUN}.feat/reg/standard2example_func.mat
	INPUT=${MASK}
	OUTPUT=${OUTPUTDIR1}/std2mni_${MASKNAME}
	flirt -in ${INPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${OUTPUT}
	fslmaths ${DATA2} -mas ${OUTPUT} ${OUTPUTDIR2}/DATA_std2mni_${MASKNAME}

	#to standard
	REF=${MAINOUTPUT}/run${RUN}.feat/reg/standard.nii.gz
	MATRIX=${MAINOUTPUT}/run${RUN}.feat/reg/example_func2standard.mat
	INPUT=${MASK}
	OUTPUT=${OUTPUTDIR3}/func2std_${MASKNAME}
#	flirt -in ${INPUT} -ref ${REF} -applyisoxfm 4 -out ${OUTPUT}
	#flirt -in ${INPUT} -ref ${REF} -out ${OUTPUT}
	fslmaths ${NEWDATA} -mas ${INPUT} ${OUTPUTDIR4}/DATA_func2std_${MASKNAME}

done
# 
# MASKNAME="air5.nii.gz"
# MASK=${ROIDIR}/${MASKNAME}
# 
# #to native
# REF=${MAINOUTPUT}/run${RUN}.feat/reg/example_func.nii.gz
# #MATRIX=${MAINOUTPUT}/run${RUN}.feat/reg/standard2example_func.mat
# INPUT=${MASK}
# OUTPUT=${OUTPUTDIR1}/std2mni_${MASKNAME}
# #flirt -in ${INPUT} -ref ${REF} -out ${OUTPUT}
# #fslmaths ${DATA} -mas ${OUTPUT} ${OUTPUTDIR2}/DATA_std2mni_${MASKNAME}
# fslmaths ${DATA} -mas ${INPUT} ${OUTPUTDIR2}/DATA_std2mni_${MASKNAME}
# fslmeants -i ${OUTPUTDIR2}/DATA_std2mni_${MASKNAME} -o ${OUTPUTDIR5}/${SUBJ}_region117_new.txt -m ${MASK}
# 
# #to standard
# REF=${MAINOUTPUT}/run${RUN}.feat/reg/standard.nii.gz
# MATRIX=${MAINOUTPUT}/run${RUN}.feat/reg/example_func2standard.mat
# INPUT=${MASK}
# OUTPUT=${OUTPUTDIR3}/func2std_${MASKNAME}
# #flirt -in ${INPUT} -ref ${REF} -applyisoxfm 4 -init ${MATRIX} -out ${OUTPUT}
# flirt -in ${INPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${OUTPUT}
# 
# fslmaths ${NEWDATA2} -mas ${OUTPUT} ${OUTPUTDIR4}/DATA_func2std_${MASKNAME}
# fslmeants -i ${OUTPUTDIR4}/DATA_func2std_${MASKNAME} -o ${OUTPUTDIR6}/${SUBJ}_region117_new.txt -m ${OUTPUT}
# 
# 
# MASKNAME="air6.nii.gz"
# MASK=${ROIDIR}/${MASKNAME}
# 
# #to native
# REF=${MAINOUTPUT}/run${RUN}.feat/reg/example_func.nii.gz
# #MATRIX=${MAINOUTPUT}/run${RUN}.feat/reg/standard2example_func.mat
# INPUT=${MASK}
# OUTPUT=${OUTPUTDIR1}/std2mni_${MASKNAME}
# #flirt -in ${INPUT} -ref ${REF} -out ${OUTPUT}
# #fslmaths ${DATA} -mas ${OUTPUT} ${OUTPUTDIR2}/DATA_std2mni_${MASKNAME}
# fslmaths ${DATA} -mas ${INPUT} ${OUTPUTDIR2}/DATA_std2mni_${MASKNAME}
# fslmeants -i ${OUTPUTDIR2}/DATA_std2mni_${MASKNAME} -o ${OUTPUTDIR5}/${SUBJ}_region117_new2.txt -m ${MASK}
# 
# #to standard
# REF=${MAINOUTPUT}/run${RUN}.feat/reg/standard.nii.gz
# MATRIX=${MAINOUTPUT}/run${RUN}.feat/reg/example_func2standard.mat
# INPUT=${MASK}
# OUTPUT=${OUTPUTDIR3}/func2std_${MASKNAME}
# flirt -in ${INPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${OUTPUT}
# fslmaths ${NEWDATA2} -mas ${OUTPUT} ${OUTPUTDIR4}/DATA_func2std_${MASKNAME}
# fslmeants -i ${OUTPUTDIR4}/DATA_func2std_${MASKNAME} -o ${OUTPUTDIR6}/${SUBJ}_region117_new2.txt -m ${OUTPUT}
# 
# 

OUTDIR=${MAINOUTPUT}/Logs
mkdir -p $OUTDIR
rm -f ${NEWDATA2}.nii.gz




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
