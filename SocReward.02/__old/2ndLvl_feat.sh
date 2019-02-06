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

# NOTE:Set OUTDIR HERE. Don't modify/remove/comment-out the value in POST-USER section,
# It won't override the value you set but is a safe default in case you don't set one
OUTDIR=$EXPERIMENT/Analysis/Cluster/Job_logs
# NOTE:Set variables the usual way (the variable constructs in PRE/POST USER sections
# do special things that you don't need

SUBJ=$1

#data location and other variables
FSLDATADIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/denoised_CCN/$SUBJ

MAINDIR=$FSLDATADIR2
MAINOUTPUT=${MAINDIR}/${SUBJ}_feat_noTD_new2
OUTPUT=${MAINDIR}/${SUBJ}_2nd_lvl_model4_noTD
FSLDATADIR=${MAINDIR}/



#run FEAT on each run
INPUT1=${MAINOUTPUT}/${SUBJ}_run2_noTD.feat
INPUT2=${MAINOUTPUT}/${SUBJ}_run3_noTD.feat
INPUT3=${MAINOUTPUT}/${SUBJ}_run4_noTD.feat
INPUT4=${MAINOUTPUT}/${SUBJ}_run5_noTD.feat
INPUT5=${MAINOUTPUT}/${SUBJ}_run6_noTD.feat



for i in $EXPERIMENT/Analysis/Cluster/Passive/AnalysisScripts/Passive_scripts/higherlevel/'Model4_2ndLvl.fsf'; do
sed -e 's@OUTPUT@'$OUTPUT'@g' \
    -e 's@INPUT1@'$INPUT1'@g' \
    -e 's@INPUT2@'$INPUT2'@g' \
    -e 's@INPUT3@'$INPUT3'@g' \
    -e 's@INPUT4@'$INPUT4'@g' \
    -e 's@INPUT5@'$INPUT5'@g' <$i> ${FSLDATADIR}/2ndLvlFixed_${SUBJ}.fsf
done

#run the newly created fsf files
feat ${FSLDATADIR}/2ndLvlFixed_${SUBJ}.fsf

    


done


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis}  #output directory
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
