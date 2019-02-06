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


CON_NAME=$1
RUN=$2


MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask
MAINOUTPUT=${MAINDIR}/3rdLevel_noTD_NEW_flame
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/COPE${RUN}_${CON_NAME}
ANALYZED=${MAINOUTPUT}


INPUT01=${MAINDIR}/33754/33754_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT02=${MAINDIR}/33642/33642_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT03=${MAINDIR}/32953/32953_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT04=${MAINDIR}/32958/32958_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT05=${MAINDIR}/32976/32976_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT06=${MAINDIR}/32984/32984_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT07=${MAINDIR}/33035/33035_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT08=${MAINDIR}/33045/33045_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT09=${MAINDIR}/33771/33771_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT10=${MAINDIR}/33082/33082_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT11=${MAINDIR}/33135/33135_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT12=${MAINDIR}/33757/33757_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT13=${MAINDIR}/33302/33302_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT14=${MAINDIR}/33402/33402_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT15=${MAINDIR}/33456/33456_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT16=${MAINDIR}/33467/33467_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT17=${MAINDIR}/33732/33732_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT18=${MAINDIR}/33744/33744_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT19=${MAINDIR}/33746/33746_lvl2.gfeat/cope${RUN}.feat/stats/cope1.nii.gz




TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisScripts/Passive_scripts/higherlevel/3rdlevel

cd ${TEMPLATEDIR}

 echo $OUTPUT
 
dos2unix s19_flame1.fsf
 for i in 's19_flame1.fsf'; do
   sed -e 's@OUTPUT@'$OUTPUT'@g' \
   -e 's@INPUT01@'$INPUT01'@g' \
   -e 's@INPUT02@'$INPUT02'@g' \
   -e 's@INPUT03@'$INPUT03'@g' \
   -e 's@INPUT04@'$INPUT04'@g' \
   -e 's@INPUT05@'$INPUT05'@g' \
   -e 's@INPUT06@'$INPUT06'@g' \
   -e 's@INPUT07@'$INPUT07'@g' \
   -e 's@INPUT08@'$INPUT08'@g' \
   -e 's@INPUT09@'$INPUT09'@g' \
   -e 's@INPUT10@'$INPUT10'@g' \
   -e 's@INPUT11@'$INPUT11'@g' \
   -e 's@INPUT12@'$INPUT12'@g' \
   -e 's@INPUT13@'$INPUT13'@g' \
   -e 's@INPUT14@'$INPUT14'@g' \
   -e 's@INPUT15@'$INPUT15'@g' \
   -e 's@INPUT16@'$INPUT16'@g' \
   -e 's@INPUT17@'$INPUT17'@g' \
   -e 's@INPUT18@'$INPUT18'@g' \
   -e 's@INPUT19@'$INPUT19'@g' <$i> ${ANALYZED}/3rdLvlFixed_${RUN}_${CON_NAME}.fsf
 done
    
   
 #runs the analysis using the newly created fsf file
 feat ${ANALYZED}/3rdLvlFixed_${RUN}_${CON_NAME}.fsf







# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
