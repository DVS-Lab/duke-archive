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

SUBJ=SUB_SUBJ_VAR
RUN=SUB_RUN_VAR


MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask
FUNCDIR=${MAINDIR}/${SUBJ}



if [ "$SUBJ" -eq 33732 ] && [ "$RUNS" -eq 4 ]; then
	continue
fi

OUTPUTDIR=${FUNCDIR}/forPPI/standard2func_run${RUN}
mkdir -p $OUTPUTDIR

for ROI in "overlap_vmPFC_4mm" "choice_mOFC_4mm" "overlap_vmPFC_2mm" "choice_mOFC_2mm"; do
	MASKNAME=${ROI}.nii.gz
	MASKSHORT=$ROI

	#Y:\Huettel\SocReward.01\Analysis\Cluster\PassiveTask\32918\32918_ica_6mm_ST\32918_run2.ica\crap_removed_data_v0.7.1.nii.gz

	MASK=${MAINDIR}/ROIs_functional/${MASKNAME}
	
	DATA=${FUNCDIR}/${SUBJ}_ica_6mm_ST/${SUBJ}_run${RUN}.ica/crap_removed_data_v0.7.1.nii.gz
	REF=${FUNCDIR}/${SUBJ}_ica_6mm_ST/${SUBJ}_run${RUN}.ica/example_func.nii.gz
	MATRIX=${FUNCDIR}/${SUBJ}_ica_6mm_ST/${SUBJ}_run${RUN}.ica/reg/standard2example_func.mat
	INPUT=${MASK}
	OUTPUT=${OUTPUTDIR}/${MASKSHORT}

	FLIRT_CMD="flirt -in ${INPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${OUTPUT}"
	eval $FLIRT_CMD
	echo $FLIRT_CMD

	OUTPUT_TXT=${OUTPUTDIR}/${MASKSHORT}_ts.txt
	FSLMEANTS_CMD="fslmeants -i ${DATA} -o ${OUTPUT_TXT} -m ${OUTPUT}"
	eval $FSLMEANTS_CMD
	echo $FSLMEANTS_CMD

done

OUTDIR=$MAINDIR/PPI_logs
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
