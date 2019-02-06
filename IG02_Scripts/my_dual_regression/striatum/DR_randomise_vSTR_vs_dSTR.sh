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
# #$ -M jac44@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02
sleep 5s

SPLIT=$1
ICAOUTPUT=gica_TaskRest_split${SPLIT}_striatum_smoothed #or gica_TaskOnly_split2_striatum_smoothed.ica
DROUTPUT=DR_wb_corrected_Task_Xsplit #what is the base output dir of your dual regression?
ICNAME=dr_stage2_${2} # dr_stage2_dSTR_minus_vSTR 
MODEL=mid_split${SPLIT} #mid_split1 or mid_split2
NCONTRASTS=4 #how many contrasts are in your design.con file?


MAINDIR=/mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02/Analysis/TaskData/groupICA_AU/DVS/StriatumParcellation
OUTPUT=$MAINDIR/${ICAOUTPUT}.ica/${DROUTPUT}

$FSLDIR/bin/randomise -i $OUTPUT/$ICNAME -o $OUTPUT/dr_stage3b_ic${2} -m $OUTPUT/mask -d $MAINDIR/StriatumModels/${MODEL}.mat -t $MAINDIR/StriatumModels/${MODEL}.con -n 10000 -T -V
#threshold output
for C in `seq $NCONTRASTS`; do
	OUTIMAGE=dr_stage3b_ic${2}_tfce_corrp_tstat${C}
	$FSLDIR/bin/fslmaths $OUTPUT/$OUTIMAGE -thr 0.95 $OUTPUT/thresh_${OUTIMAGE}
	overlay 1 0 ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -a $OUTPUT/${OUTIMAGE} .95 1 $OUTPUT/renderedthresh_${OUTIMAGE}
	slicer $OUTPUT/renderedthresh_${OUTIMAGE} -S 2 750 $OUTPUT/renderedthresh_${OUTIMAGE}.png

done
OUTDIR=$MAINDIR/Logs/randomise

mkdir -p $OUTDIR

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
