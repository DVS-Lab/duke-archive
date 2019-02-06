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

# 
# FSLDIR=/usr/local/packages/fsl-4.1.8
# . ${FSLDIR}/etc/fslconf/fsl.sh
# PATH=${FSLDIR}/bin:${PATH}
# export FSLDIR PATH

SUBJ=$1
RUN=$2
SMOOTH=0
GO=1
FNIRT=1


SKIP=0
if [ $SUBJ -eq 1020 -a $RUN -eq 5 ]; then
	SKIP=1
fi
if [ $SUBJ -eq 1023 -a $RUN -eq 5 ]; then
	SKIP=1
fi




MAINDIR=${EXPERIMENT}/Analysis


if [ $FNIRT -eq 1 ]; then
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/run${RUN}
else
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/run${RUN}
fi


INDATA=${OUTPUT}.feat/prestats_phase2_2resample.ica/filtered_func_data.nii.gz
NVOLUMES=`fslnvols $INDATA`
OUTPUTREAL=${OUTPUT}.feat/prestats_phase2_2resample.ica
OUTDATA=${OUTPUTREAL}/unconfounded_data.nii.gz

if [ $GO -eq 1 ]; then
	rm -rf $OUTDATA
	rm -rf ${OUTPUTREAL}/std_unconfounded_data.nii.gz
fi
if [ -e $OUTDATA ]; then
	SKIP=1
fi
preMAT=${OUTPUTREAL}/for_confound.txt
cp ${OUTPUT}.feat/for_confound.txt ${OUTPUTREAL}/.
postMAT=${OUTPUTREAL}/for_unconfound.mat

FEATOUTPUT=${OUTPUT}.feat
if [ $SKIP -eq 1 ]; then
	echo "not running unconfound for exceptions or ones that are already done..."
else
	TEMPLATEDIR=${MAINDIR}/FSL/templates
	cd ${TEMPLATEDIR}
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@DATA@'$INDATA'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	-e 's@UNCONFOUNDFILE@'$preMAT'@g' \
	<make_confoundmat.fsf> ${OUTPUTREAL}/for_unconfound.fsf
	feat_model ${OUTPUTREAL}/for_unconfound ${preMAT}
	unconfound ${INDATA} ${OUTDATA} ${postMAT}

	${FSLDIR}/bin/applywarp --ref=${FEATOUTPUT}/reg/standard --in=${OUTPUTREAL}/unconfounded_data --out=${OUTPUTREAL}/std_unconfounded_data --warp=${FEATOUTPUT}/reg/highres2standard_warp --premat=${FEATOUTPUT}/reg/example_func2highres.mat --interp=sinc

fi

OUTDIR=$MAINDIR/FSL/Logs/unconfound
mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
