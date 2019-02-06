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
#$ -m ea
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
#$ -M smith@biac.duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


SUBJ=$1
RUN=$2
SMOOTH=$3
SESSION=$4


MAINDIR=${EXPERIMENT}/Analysis/FSL_Analyses
MAINDIR2=${EXPERIMENT}/Analysis

SUBJDIR=${MAINDIR}/PreStatsOnly/Smooth_${SMOOTH}mm/${SUBJ}_prestats

MAINOUTPUT=${SUBJDIR}
OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
FUNCDIR=${MAINOUTPUT}
ROIDIR=${MAINDIR}/ROIs_aal_MNI_V4

OUTPUTDIR1=${FUNCDIR}/ROI_data/func2standard_masks/run${RUN}
OUTPUTDIR2=${FUNCDIR}/ROI_data/standard2func_masks/run${RUN}
OUTPUTDIR3=${FUNCDIR}/ROI_data/standata2func_DATA/run${RUN}

mkdir -p $OUTPUTDIR1
mkdir -p $OUTPUTDIR2
mkdir -p $OUTPUTDIR3

cd $ROIDIR
ls -1 *.nii.gz > roifile


REF=${FUNCDIR}/run${RUN}.feat/reg/example_func.nii.gz
DATA=${FUNCDIR}/run${RUN}.feat/new_filtered_func_data.nii.gz
MATRIX=${FUNCDIR}/run${RUN}.feat/reg/standard2example_func.mat


cat $ROIDIR/roifile|while read LINE; do

	MASKNAME=$LINE
	MASK=${ROIDIR}/${MASKNAME}

	INPUT=${MASK}
	OUTPUT=${OUTPUTDIR2}/mni2func_${MASKNAME}
	flirt -in ${INPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${OUTPUT}
	fslmaths ${DATA} -mas ${OUTPUT} ${OUTPUTDIR3}/DATA_mni2func_${MASKNAME}

done

OUTDIR=$MAINDIR/Cluster_Job_Logs/Masking3
mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 

mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
