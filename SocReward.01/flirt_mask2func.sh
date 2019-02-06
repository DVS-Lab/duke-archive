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

#SUBJ=$1
#RUN=$2

for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do

	
	MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask
	FUNCDIR=${MAINDIR}/${SUBJ}

	OLD_OUTPUT=${FUNCDIR}/MASKs_standard2func
	rm -rf ${OLD_OUTPUT}

	echo $FUNCDIR
	
	for RUN in 2 3 4 5 6; do
	
	if [ "$SUBJ" -eq 33732 ] && [ "$RUNS" -eq 4 ]; then
		continue
	fi

	OUTPUTDIR=${FUNCDIR}/MASKs_standard2func/standard2func_run${RUN}
	
	mkdir -p $OUTPUTDIR
	
		for LIST in "aIns.hdr aIns" "mOFC.hdr mOFC" "mPFC.hdr mPFC" "NAcc.hdr NAcc" "rFFA.hdr rFFA"; do
		set -- $LIST
		MASKNAME=$1
		MASKSHORT=$2
	
	
		
		MASK=${MAINDIR}/ROIs_newest/${MASKNAME}
		
		REF=${FUNCDIR}/${SUBJ}_Model7.1_NoMotor_6mm_ST_v0.7.1/${SUBJ}_run${RUN}_crap_removed.feat/example_func.nii.gz
		MATRIX=${FUNCDIR}/${SUBJ}_Model7.1_NoMotor_6mm_ST_v0.7.1/${SUBJ}_run${RUN}_crap_removed.feat/reg/standard2example_func.mat
		INPUT=${MASK}
		OUTPUT=${OUTPUTDIR}/${MASKSHORT}_standard2func
	
		FLIRTCMD="flirt -in ${INPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${OUTPUT}"
		eval $FLIRTCMD
		echo $FLIRTCMD
		
		done
	done
done





OUTDIR=$MAINDIR/
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