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
RUN=$3
SMOOTH=0
FNIRT=$2



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

STANDARD=${EXPERIMENT}/Analysis/FSL/MNIdiffeo
DATA=${OUTPUT}.feat/filtered_func_data
INITIALHR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/wholebrainEPI_0mm_smooth/run3.feat/example_func
cd ${OUTPUT}.feat
# rm -rf regforJAC
mkdir regforJAC
# example_func --> highres --> standard
# anat_brain -- highres --> standard

${FSLDIR}/bin/fslmaths $DATA regforJAC/data #filteredfunc
${FSLDIR}/bin/fslmaths $INITIALHR regforJAC/highres #wholebrainEPI
${FSLDIR}/bin/fslmaths $ANAT regforJAC/anat_brain #anatomical
${FSLDIR}/bin/fslmaths $STANDARD regforJAC/standard
${FSLDIR}/bin/bet mean_func mean_func_brain -f 0.3 -m
mv example_func.nii.gz old_example_func.nii.gz
${FSLDIR}/bin/fslmaths old_example_func -mas mean_func_brain_mask example_func
${FSLDIR}/bin/fslmaths example_func regforJAC/example_func #examplefunc
${FSLDIR}/bin/fslmaths $STANDARD -bin -dilF -dilF regforJAC/standard_mask -odt char
cd regforJAC

#affine
${FSLDIR}/bin/flirt -ref highres -in example_func -out example_func2highres -omat example_func2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
${FSLDIR}/bin/convert_xfm -inverse -omat highres2example_func.mat example_func2highres.mat
${FSLDIR}/bin/flirt -ref standard -in highres -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform

if [ $FNIRT -eq 1 ]; then
	#nonlinear
	${FSLDIR}/bin/fnirt --in=highres --aff=highres2standard.mat --cout=highres2standard_warp --iout=highres2standard --jout=highres2standard_jac --config=T1_2_MNI152_2mm --ref=standard --refmask=standard_mask --warpres=9,9,9 --applyrefmask=0,1,1,1,1,1
	${FSLDIR}/bin/convert_xfm -inverse -omat standard2highres.mat highres2standard.mat
	${FSLDIR}/bin/convert_xfm -omat example_func2standard.mat -concat highres2standard.mat example_func2highres.mat
	${FSLDIR}/bin/applywarp --ref=standard --in=example_func --out=example_func2standard --warp=highres2standard_warp --premat=example_func2highres.mat --interp=sinc
	${FSLDIR}/bin/convert_xfm -inverse -omat standard2example_func.mat example_func2standard.mat
	${FSLDIR}/bin/applywarp --ref=standard --in=data --out=data2standard --warp=highres2standard_warp --premat=example_func2highres.mat --interp=sinc
else
	#move data
	${FSLDIR}/bin/convert_xfm -omat example_func2standard.mat -concat highres2standard.mat example_func2highres.mat
	${FSLDIR}/bin/flirt -ref standard -in example_func -out example_func2standard -applyxfm -init example_func2standard.mat -interp sinc -sincwindow hanning -usesqform
	${FSLDIR}/bin/flirt -ref standard -in data -out data2standard -applyxfm -init example_func2standard.mat -interp sinc -sincwindow hanning -usesqform
fi

#affine anat to standard
${FSLDIR}/bin/flirt -ref highres -in anat_brain -out anat_brain2highres -omat anat_brain2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
${FSLDIR}/bin/convert_xfm -inverse -omat highres2anat_brain.mat anat_brain2highres.mat
${FSLDIR}/bin/convert_xfm -omat anat_brain2standard.mat -concat highres2standard.mat anat_brain2highres.mat
${FSLDIR}/bin/flirt -ref standard -in anat_brain -out anat_brain2standard -applyxfm -init anat_brain2standard.mat -interp sinc -sincwindow hanning -usesqform
${FSLDIR}/bin/convert_xfm -inverse -omat standard2anat_brain.mat anat_brain2standard.mat

rm data.nii.gz

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
