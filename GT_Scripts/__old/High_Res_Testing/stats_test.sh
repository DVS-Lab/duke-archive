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

FSLDIR=/usr/local/fsl-4.1.4-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh



SUBJ=$1
RUN=$2
ISFNIRT=$3

MAINDIR=$EXPERIMENT/Analysis/SequenceTest

if [ $ISFNIRT -eq 1 ]; then
	OUTPUT=$MAINDIR/run${RUN}_fnirt
else
	OUTPUT=$MAINDIR/run${RUN}
fi

ANAT=$MAINDIR/${SUBJ}_anat_brain.nii.gz
COPLANAR=$MAINDIR/${SUBJ}_coplanar_brain.nii.gz
DATA=$MAINDIR/run${RUN}.nii.gz

if [ $RUN -eq 1 ]; then
	CONDA=$MAINDIR/L_FacesLandscapes.txt
	CONDB=$MAINDIR/F_FacesLandscapes.txt
	NVOLUMES=476
	SET_TR=1.58
	SMOOTH=6
fi

if [ $RUN -eq 2 ]; then
	CONDA=$MAINDIR/L_VisuoMotor.txt
	CONDB=$MAINDIR/R_VisuoMotor.txt
	NVOLUMES=482
	SET_TR=1.58
	SMOOTH=6
fi

if [ $RUN -eq 3 ]; then
	CONDA=$MAINDIR/L_HR_FacesLandscapes.txt
	CONDB=$MAINDIR/F_HR_FacesLandscapes.txt
	NVOLUMES=380
	SET_TR=2
	SMOOTH=3
fi



TEMPLATE=${MAINDIR}/template.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@CONDA@'$CONDA'@g' \
-e 's@CONDB@'$CONDB'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@SET_TR@'$SET_TR'@g' \
-e 's@COPLANAR@'$COPLANAR'@g' \
-e 's@ISFNIRT@'$ISFNIRT'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
<$TEMPLATE> ${MAINDIR}/FEAT_0${RUN}.fsf

$FSLDIR/bin/feat ${MAINDIR}/FEAT_0${RUN}.fsf


OUTDIR=${MAINDIR}/Logs
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
