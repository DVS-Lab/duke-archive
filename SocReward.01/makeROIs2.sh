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

SUBJ=$1
RUN=$2

for SMOOTH in "0" "6.0"; do

	MAINDIR=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance
	ROIDIR=${MAINDIR}/ROIs_StandardSpace
	
	FUNCDIR=${MAINDIR}/${SUBJ}/${SUBJ}_FEAT_face_${SMOOTH}mm_smoothed
	
	if [ "$SMOOTH" == "0" ]; then
		SMOOTH2=0
	else
		SMOOTH2=6
	fi

	OUTPUTDIR1=${MAINDIR}/${SUBJ}/ROI_data_${SMOOTH2}mm_smoothed/run${RUN}
	OUTPUTDIR2=${MAINDIR}/${SUBJ}/ROI_data_${SMOOTH2}mm_smoothed/run${RUN}/data5
	OUTPUTDIR3=${MAINDIR}/${SUBJ}/ROI_data_${SMOOTH2}mm_smoothed/run${RUN}/mask5


	rm -rf $OUTPUTDIR1
	rm -rf $OUTPUTDIR2
	rm -rf $OUTPUTDIR3

	mkdir -p $OUTPUTDIR1
	mkdir -p $OUTPUTDIR2
	mkdir -p $OUTPUTDIR3

	REF=${FUNCDIR}/${SUBJ}_run${RUN}.feat/reg/standard.nii.gz
	DATA=${FUNCDIR}/${SUBJ}_run${RUN}.feat/filtered_func_data.nii.gz
	MATRIX=${FUNCDIR}/${SUBJ}_run${RUN}.feat/reg/example_func2standard.mat
	INPUT=${MASK}
	OUTPUT=${OUTPUTDIR1}/func2standard

	flirt -in ${DATA} -ref ${REF} -applyisoxfm 4 -init ${MATRIX} -out ${OUTPUT}
	


	#for LIST in "air.hdr air" "L_FFA2.hdr L_FFA2" "L_IPS2.hdr L_IPS2" "R_FFA2.hdr R_FFA2" "R_IPS2.hdr R_IPS2" "R_DLPFC.hdr R_DLPFC" "L_DLPFC.hdr L_DLPFC" "vmPFC.hdr vmPFC" "PCC2.hdr PCC2"; do
	for LIST in "bg_image.nii.gz wholebrain"; do
		set -- $LIST
		MASKNAME=$1
		MASKSHORT=$2
		
		MASK=${ROIDIR}/${MASKNAME}
		MASK2=${OUTPUTDIR3}/${MASKSHORT}_resampled

		flirt -in ${MASK} -ref ${REF} -applyisoxfm 4 -out ${MASK2}
		fslmaths ${OUTPUT} -mas ${MASK2} ${OUTPUTDIR2}/${MASKSHORT}_data_func2mni_run${RUN}
		

	done

done


OUTDIR=$MAINDIR/Job_Logs/Masking5
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
