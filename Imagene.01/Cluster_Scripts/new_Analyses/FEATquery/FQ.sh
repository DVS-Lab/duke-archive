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
# #$ -M smith@biac.duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here



SUBJ=SUB_SUBNUM_SUB
GO=SUB_GO_SUB
#COPENUM=SUB_COPE_SUB

for COPENUM in `seq 20`; do
	
	#M:\Imagene.01\Analysis\Framing\FSL\ROIs\fromM7
	
	MAINDIR=${EXPERIMENT}/Analysis/Framing/FSL
	#M:\Imagene.01\Analysis\Framing\FSL\47725\47725_model7.gfeat\cope18.feat
	#/home/smith/experiments/Imagene.01/Analysis/Framing/FSL/47752/NoLapses/model10.gfeat

	COPE=${MAINDIR}/${SUBJ}/NoLapses/model10.gfeat/cope${COPENUM}.feat
	
	for MASKNAME in "aVMPFC_5mm" "CNR1_self-char" "dmPFC_5mm" "dmPFC_loss-gain" "IFG_5mm" "midTG_5mm" "pSTC_5mm" "pVMPFC_5mm" "vmPFC_gain-loss"; do
		MASK=${MAINDIR}/ROIs/${MASKNAME}.nii.gz
	
		if [ $GO -eq 1 ]; then
			rm -rf $COPE/${MASKNAME}_FQ
		fi

		if [ ! -s $COPE/${MASKNAME}_FQ/report.txt ]; then
			rm -rf $COPE/${MASKNAME}_FQ
		fi

		if [ -d $COPE/${MASKNAME}_FQ ]; then
			echo "FQ output exists! skipping...."
		else
			featquery 1 ${COPE} 1  stats/pe1 ${MASKNAME}_FQ -p ${MASK}
		fi

	done
done


OUTDIR=$MAINDIR/FQ_logs
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
