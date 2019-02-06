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

SUBJ=SUB_SUBNUM_SUB
SMOOTH=SUB_SMOOTH_SUB
GO=SUB_GO_SUB
FNIRT=SUB_FNIRT_SUB

MAINDIR=${EXPERIMENT}/Analysis
if [ $FNIRT -eq 1 ]; then
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model02_FNIRT/Smooth_${SMOOTH}mm
else
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model02_FLIRT/Smooth_${SMOOTH}mm
fi

OUTPUT=$MAINOUTPUT/Level2

if [ $GO -eq 1 ]; then
	rm -rf $OUTPUT.gfeat
fi

INPUT01=$MAINOUTPUT/run1.feat
INPUT02=$MAINOUTPUT/run2.feat
INPUT03=$MAINOUTPUT/run3.feat
INPUT04=$MAINOUTPUT/run4.feat


TEMPLATE=${MAINDIR}/FSL/Templates/L2_model02.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@INPUT01@'$INPUT01'@g' \
-e 's@INPUT02@'$INPUT02'@g' \
-e 's@INPUT03@'$INPUT03'@g' \
-e 's@INPUT04@'$INPUT04'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_L2.fsf

if [ -d ${OUTPUT}.gfeat ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_L2.fsf
fi

#delete unnecessary files
for C in `seq $NCOPES`; do
	rm -rf ${OUTPUT}.gfeat/cope${C}.feat/stats/res4d.nii.gz
	rm -rf ${OUTPUT}.gfeat/cope${C}.feat/filtered_func_data.nii.gz
	rm -rf ${OUTPUT}.gfeat/cope${C}.feat/var_filtered_func_data.nii.gz
done


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
