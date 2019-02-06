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

SUBJ=$1
OPTION=$2
NEG=$3
SCALEDONLY=$4

SMOOTH=6


MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask


if [ $SCALEDONLY == "no" ]; then

	TEMPLATE=level2_template_model10+11.fsf
	TEMPLATE2=level2_template33732_model10+11.fsf
	NCOPES=2

	if [ $NEG == "yes" ]; then
		MAINDIR2=${MAINDIR}/${SUBJ}/${SUBJ}_Model10_neg_scaled_${OPTION}_NoMotor_6mm_ST
	else
		MAINDIR2=${MAINDIR}/${SUBJ}/${SUBJ}_Model10_scaled_${OPTION}_NoMotor_6mm_ST
	fi

else

	TEMPLATE=level2_template_model10+11_scaledonly.fsf
	TEMPLATE2=level2_template33732_model10+11_scaledonly.fsf
	NCOPES=1

	if [ $NEG == "yes" ]; then
		MAINDIR2=${MAINDIR}/${SUBJ}/${SUBJ}_Model10_neg_scaledonly_${OPTION}_NoMotor_6mm_ST
	else
		MAINDIR2=${MAINDIR}/${SUBJ}/${SUBJ}_Model10_scaledonly_${OPTION}_NoMotor_6mm_ST
	fi
	
fi


OUTPUT=${MAINDIR2}/${SUBJ}_2ndlevel_${OPTION}
REALOUTPUT=${OUTPUT}.gfeat




rm -rf ${REALOUTPUT}

TEMPLATEDIR=${MAINDIR}/AnalysisTemplates/higherlevel
cd $TEMPLATEDIR

if [ $SUBJ -eq 33732 ]; then
	INPUT1=${MAINDIR2}/${SUBJ}_run2.feat
	INPUT2=${MAINDIR2}/${SUBJ}_run3.feat
	INPUT4=${MAINDIR2}/${SUBJ}_run5.feat
	INPUT5=${MAINDIR2}/${SUBJ}_run6.feat
	
	for i in $TEMPLATE2; do
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	    -e 's@INPUT1@'$INPUT1'@g' \
	    -e 's@INPUT2@'$INPUT2'@g' \
	    -e 's@INPUT4@'$INPUT4'@g' \
	    -e 's@INPUT5@'$INPUT5'@g' <$i> ${MAINDIR2}/2ndLvlFixed_${SUBJ}.fsf
	done

else
	INPUT1=${MAINDIR2}/${SUBJ}_run2.feat
	INPUT2=${MAINDIR2}/${SUBJ}_run3.feat
	INPUT3=${MAINDIR2}/${SUBJ}_run4.feat
	INPUT4=${MAINDIR2}/${SUBJ}_run5.feat
	INPUT5=${MAINDIR2}/${SUBJ}_run6.feat
	

	for i in $TEMPLATE; do
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	    -e 's@INPUT1@'$INPUT1'@g' \
	    -e 's@INPUT2@'$INPUT2'@g' \
	    -e 's@INPUT3@'$INPUT3'@g' \
	    -e 's@INPUT4@'$INPUT4'@g' \
	    -e 's@INPUT5@'$INPUT5'@g' <$i> ${MAINDIR2}/2ndLvlFixed_${SUBJ}.fsf
	done
fi

cd ${MAINDIR2}
if [ -d $REALOUTPUT ]; then
	echo "This one is already done. Exiting script..."
	exit
else
	feat ${MAINDIR2}/2ndLvlFixed_${SUBJ}.fsf

	cd $REALOUTPUT
	for j in `seq $NCOPES`; do
	
		COPE=cope${j}.feat
		cd $COPE
		rm -f filtered_func_data.nii.gz
		rm -f var_filtered_func_data.nii.gz

		cd ..
	
	done
	
fi

OUTDIR=$MAINDIR2

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 

mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
