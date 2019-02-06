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
##$ -m ea
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
##$ -M smith@biac.duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


CON_NAME=$1
COPE_NUM=$2
OPTION=$3

MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask
MAINOUTPUT=${MAINDIR}/L3_NEW_cons_Covariate
mkdir -p $MAINOUTPUT

OUTPUT=${MAINOUTPUT}/${OPTION}_${CON_NAME}
ANALYZED=${MAINOUTPUT}
REALOUTPUT=${OUTPUT}.gfeat

CHECK=${OUTPUT}.gfeat/cope1.feat/cluster_mask_zstat1.nii.gz
if [ ! -e $CHECK ]; then
	rm -rf ${OUTPUT}.gfeat
fi

N=0
for SUBJ in 33754 33642 32953 32958 32976 32984 33035 33045 33771 33082 33135 33757 33302 33402 33456 33467 33732 33744 33746 32918 33288 33064 33784; do 
	let N=$N+1
	NN=`printf '%02d' $N`
# 	eval INPUT${NN}=${MAINDIR}/${SUBJ}/${SUBJ}_Model9_${OPTION}_6mm_ST/${SUBJ}_2ndlevel_${OPTION}.gfeat/cope${COPE_NUM}.feat/stats/cope1.nii.gz
# 	FILE_CHECK=${MAINDIR}/${SUBJ}/${SUBJ}_Model9_${OPTION}_6mm_ST/${SUBJ}_2ndlevel_${OPTION}.gfeat/cope${COPE_NUM}.feat/stats/cope1.nii.gz

	eval INPUT${NN}=${MAINDIR}/${SUBJ}/${SUBJ}_Positive_Linear_Money/${SUBJ}_2ndlevel.gfeat/cope${COPE_NUM}.feat/stats/cope1.nii.gz
	FILE_CHECK=${MAINDIR}/${SUBJ}/${SUBJ}_Positive_Linear_Money/${SUBJ}_2ndlevel.gfeat/cope${COPE_NUM}.feat/stats/cope1.nii.gz

	if [ ! -e $FILE_CHECK ]; then
		echo $FILE_CHECK
	fi
done

TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates/higherlevel/3rdlevel
cd ${TEMPLATEDIR}
for i in 'covariate_s23.fsf'; do
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
   -e 's@INPUT19@'$INPUT19'@g' \
   -e 's@INPUT20@'$INPUT20'@g' \
   -e 's@INPUT21@'$INPUT21'@g' \
   -e 's@INPUT22@'$INPUT22'@g' \
   -e 's@INPUT23@'$INPUT23'@g' \
   <$i> ${ANALYZED}/L3_${CON_NAME}_${OPTION}.fsf
done


if [ -d ${REALOUTPUT} ]; then
	echo "This one is already done... skipping to the next one..."
else
	feat ${ANALYZED}/L3_${CON_NAME}_${OPTION}.fsf
	cd $REALOUTPUT
	cd cope1.feat
	rm -f filtered_func_data.nii.gz
	rm -f var_filtered_func_data.nii.gz
	rm -f stats/res4d.nii.gz
fi

OUTDIR=${MAINOUTPUT}/Logs
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
