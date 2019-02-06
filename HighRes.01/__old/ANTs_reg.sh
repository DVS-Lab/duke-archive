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
SMOOTH=$3
FNIRT=1


MAINDIR=${EXPERIMENT}/Analysis

ANATH=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat
ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
if [ $FNIRT -eq 1 ]; then
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/run${RUN}
else
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/run${RUN}
fi


STANDARD=${MAINDIR}/FSL/MNI152_T1_1.8mm_brain
STANDARDH=${MAINDIR}/FSL/MNI152_T1_1.8mm



# # ${FSLDIR}/bin/fslmaths $INITIALHR reg/initial_highres
# # ${FSLDIR}/bin/fslmaths $ANAT reg/highres
# # ${FSLDIR}/bin/fslmaths $STANDARD reg/standard
# # ${FSLDIR}/bin/fslmaths $STANDARDH reg/standard_head
# # ${FSLDIR}/bin/fslmaths $ANATH  reg/highres_head
# # ${FSLDIR}/bin/fslmaths example_func reg/example_func
# # ${FSLDIR}/bin/fslmaths $STANDARD -bin -dilF -dilF reg/standard_mask -odt char

FUNCTIMG=${OUTPUT}.feat/filtered_func_data.nii.gz
ANATIMG=${OUTPUT}.feat/reg/highres.nii.gz
#ANATSUB=rAnatomicalPhysACOrigSub.nii
TEMPLATE=${EXPERIMENT}/Analysis/FSL/MNIdiffeo.nii.gz
#TEMPLATESUB=CombinedContPatTemplate_3_3_3_wPhysOrig.nii
OUT=${OUTPUT}.feat/reg/TEST
OUTA=${OUTPUT}.feat/reg/rAnatomicalPhysACOrig
# below mapping names determined automatically below by ants.sh 
DIFFMAP=${OUTA}Warp.nii.gz
AFFMAP=${OUTA}Affine.txt
RIGIDMAP=${OUT}Affine.txt

# first Compute: AnatomicalImage Rigid=> FunctionalImage
# would probably improve with brain only target image
${ANTSPATH}ANTS 3 -m MI[${ANATIMG},${FUNCTIMG},1,32] -o ${OUT} --rigid-affine true -i 0


# Apply with a smaller reference image
# # ${ANTSPATH}ResampleImageBySpacing 3 ${ANATIMG} $ANATSUB 3 3 3
${ANTSPATH}WarpImageMultiTransform 3 ${FUNCTIMG} ${OUT}funct2.nii.gz -R $TEMPLATE ${OUT}Affine.txt


# get the map to the template - here using an existing shell script, no mask :
# Template DIFF=> Aff=> Individual 
#sh ${ANTSPATH}ants.sh 3 $TEMPLATE ${ANATIMG}
# generates call below:
${ANTSPATH}ANTS 3 -m PR[${TEMPLATE},${ANATIMG},1,4] -t SyN[0.25] -r Gauss[3,0] -o $OUTA -i 10x0x0 --use-Histogram-Matching 


# Apply to map to 3mm template space
# Template DIFF=> Aff=> Individual Rigid=> Functional 
# the command reflects the syntax above 
${ANTSPATH}WarpImageMultiTransform 3 ${FUNCTIMG} ${OUT}funct2template.nii.gz -R $TEMPLATE $DIFFMAP $AFFMAP $RIGIDMAP




OUTDIR=${MAINOUTPUT}/Logs
mkdir -p $OUTDIR

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
