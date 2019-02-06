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
run=$2
PROCESSTYPE=$3
PREPROCESSOPTION=$4



ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINDIR=${EXPERIMENT}/Analysis/Cluster/NegPE_tests/${SUBJ}/${PROCESSTYPE}
MAINOUTPUT=${MAINDIR}/${SUBJ}_${PREPROCESSOPTION}_model6
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates/feat

mkdir -p ${MAINOUTPUT}

DATA=${MAINDIR}/run${run}.nii.gz
OUTPUT=${MAINOUTPUT}/${SUBJ}_run${run}
OUTPUTREAL=${OUTPUT}.feat

if [ -d $OUTPUTREAL ]; then
	
	cd $OUTPUTREAL
	if [ ! -e cluster_mask_zstat1.nii.gz ]; then
		echo "DNF!!!!"
		cd ..
		rm -r $OUTPUTREAL
	fi

fi



FSLEVDIR=${EXPERIMENT}/Analysis/FSL/EV_Logs_3-10-08_new/Model_6/${SUBJ}/Passive


cd ${TEMPLATEDIR}
let "run2=${run}-1"
FACE=${FSLEVDIR}/Run${run2}/Run${run2}_Face_${SUBJ}.txt
MONEY=${FSLEVDIR}/Run${run2}/Run${run2}_Money_${SUBJ}.txt
MOTORRESPONSE=${FSLEVDIR}/Run${run2}/Run${run2}_MotorResponse_${SUBJ}.txt


if [ "$PREPROCESSOPTION" == "noST_50s" ]; then

	PREPROCESS=1
	HIGHPASS=50
	SLICE=0
	FILTER=1
	SMOOTH=6

elif [ "$PREPROCESSOPTION" == "ST_50s" ]; then

	PREPROCESS=1
	HIGHPASS=50
	SLICE=5
	FILTER=1
	SMOOTH=6

elif [ "$PREPROCESSOPTION" == "normal" ]; then

	PREPROCESS=1
	HIGHPASS=100
	SLICE=5
	FILTER=1
	SMOOTH=6

elif [ "$PREPROCESSOPTION" == "no_preprocess_nofilter" ]; then

	PREPROCESS=0
	HIGHPASS=0
	SLICE=0
	FILTER=100
	SMOOTH=0

elif [ "$PREPROCESSOPTION" == "normal_50s" ]; then

	PREPROCESS=1
	HIGHPASS=1
	SLICE=5
	FILTER=50
	SMOOTH=6

elif [ "$PREPROCESSOPTION" == "MC_only" ]; then

	PREPROCESS=1
	HIGHPASS=0
	SLICE=0
	FILTER=100
	SMOOTH=0

fi



if [ "$PROCESSTYPE" == "8disdaqs_only" ]; then 

	NVOLUMES=114
	NDISDAQS=0

elif [ "$PROCESSTYPE" == "original" ]; then 

	NVOLUMES=122
	NDISDAQS=8

elif [ "$PROCESSTYPE" == "rescaled_only" ]; then 

	NVOLUMES=122
	NDISDAQS=8

elif [ "$PROCESSTYPE" == "rescaled_8disdaqs" ]; then 

	NVOLUMES=114
	NDISDAQS=0

fi



if [ "$PROCESSTYPE" == "original" ] || [ "$PROCESSTYPE" == "rescaled_only" ] && [ "$PREPROCESSOPTION" == "no_preprocess_nofilter" ]; then

	DATA=${MAINDIR}/run${run}.nii.gz
	DATA2=${MAINDIR}/run${run}_new.nii.gz

	if [ -e $DATA2 ]; then
		rm -f $DATA2
	fi

	ROICMD="fslroi $DATA $DATA2 8 114"
	eval $ROICMD
	
	DATA=$DATA2
	NVOLUMES=114
	NDISDAQS=0

fi


if [ -e $MOTORRESPONSE ]; then
	CONVOLVE=3
	SHAPE=3
else
	CONVOLVE=0
	SHAPE=10
fi

for i in 'reward_model_6_template.fsf'; do
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@MONEY@'$MONEY'@g' \
	-e 's@FACE@'$FACE'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@CONVOLVE@'$CONVOLVE'@g' \
	-e 's@SHAPE@'$SHAPE'@g' \
	-e 's@MOTORRESPONSE@'$MOTORRESPONSE'@g' \
	-e 's@PREPROCESS@'$PREPROCESS'@g' \
	-e 's@HIGHPASS@'$HIGHPASS'@g' \
	-e 's@SLICE@'$SLICE'@g' \
	-e 's@FILTER@'$FILTER'@g' \
	-e 's@SMOOTH@'$SMOOTH'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	-e 's@NDISDAQS@'$NDISDAQS'@g' \
	<$i> ${MAINOUTPUT}/FEAT_0${run}.fsf
done


cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	feat ${MAINOUTPUT}/FEAT_0${run}.fsf
	#cd ${OUTPUTREAL}
	#rm -f filtered_func_data.nii.gz
fi
 
OUTDIR=${MAINOUTPUT}/logs
mkdir -p ${OUTDIR}

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
