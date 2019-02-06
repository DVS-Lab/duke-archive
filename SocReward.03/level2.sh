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

FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh


SUBJ=SUB_SUBJ
MODEL=SUB_MODEL
GO=SUB_GO
TASK=SUB_TASK
DENOISED=SUB_DENOISED
ISO=SUB_ISO

MAINDIR=${EXPERIMENT}/Analysis/FSL
SUBJECT_MAIN=${MAINDIR}/${SUBJ}


if [ $DENOISED -eq 1 -a $ISO -eq 0 ]; then
	SUBJDIR=${SUBJECT_MAIN}/${TASK}/GLM3_denoised/$MODEL
elif [ $DENOISED -eq 0 -a $ISO -eq 0 ]; then
	SUBJDIR=${SUBJECT_MAIN}/${TASK}/GLM3/$MODEL
elif [ $DENOISED -eq 1 -a $ISO -eq 1 ]; then
	SUBJDIR=${SUBJECT_MAIN}/${TASK}/GLM3_denoised_4x4x4mm/$MODEL
elif [ $DENOISED -eq 0 -a $ISO -eq 1 ]; then
	SUBJDIR=${SUBJECT_MAIN}/${TASK}/GLM3_4x4x4mm/$MODEL
fi
mkdir -p $SUBJDIR

rm -rf ${SUBJECT_MAIN}/Passive_Cued

MAINOUTPUT=${SUBJDIR}
OUTPUT=${MAINOUTPUT}/${SUBJ}_level2
OUTPUTREAL=${OUTPUT}.gfeat
 
if [ $GO -eq 1 ]; then
	rm -rf $OUTPUTREAL
fi

if [ $SUBJ -eq 35086 ] && [ "$TASK" == "PassiveCued" ]; then
	exit
fi

if [ "$MODEL" == "Model_1" ]; then
	NCOPES=28
elif [ "$MODEL" == "Model_2_Face" ] || [ "$MODEL" == "Model_2_Money" ]; then
	NCOPES=11
elif [ "$MODEL" == "Model_3" ]; then
	if [ "$TASK" == "Passive" ]; then
		NCOPES=6
	else
		NCOPES=10
	fi
elif [ "$MODEL" == "Model_4_Face" ] || [ "$MODEL" == "Model_4_Money" ]; then
	if [ "$TASK" == "Passive" ]; then
		NCOPES=2
	else
		NCOPES=3
	fi
fi

if [ -d $OUTPUTREAL ]; then
	cd $OUTPUTREAL
	if [ -d cope1.feat ] && [ -d cope${NCOPES}.feat ]; then
		cd cope1.feat
		if [ -e cluster_mask_zstat1.nii.gz ]; then
			COPE1_GOOD=1
		else
			COPE1_GOOD=0
		fi
		cd cope${NCOPES}.feat
		if [ -e cluster_mask_zstat1.nii.gz ] && [ $COPE1_GOOD -eq 1 ]; then
			exit
		else
			cd $MAINDIR
			rm -rf $OUTPUTREAL
		fi
	else
		cd $MAINDIR
		rm -rf $OUTPUTREAL
	fi
fi

TEMPLATEDIR=${MAINDIR}/Templates
cd $TEMPLATEDIR
if [ "$TASK" == "Passive" ]; then
	INPUT01=${SUBJDIR}/run1.feat
	INPUT02=${SUBJDIR}/run2.feat
	INPUT03=${SUBJDIR}/run3.feat
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@NCOPES@'$NCOPES'@g' \
	-e 's@INPUT01@'$INPUT01'@g' \
	-e 's@INPUT02@'$INPUT02'@g' \
	-e 's@INPUT03@'$INPUT03'@g' \
	<level2_3inputs.fsf> ${MAINOUTPUT}/2ndLvlFixed_${SUBJ}.fsf
else
	INPUT01=${SUBJDIR}/run1.feat
	INPUT02=${SUBJDIR}/run2.feat
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@NCOPES@'$NCOPES'@g' \
	-e 's@INPUT01@'$INPUT01'@g' \
	-e 's@INPUT02@'$INPUT02'@g' \
	<level2_2inputs.fsf> ${MAINOUTPUT}/2ndLvlFixed_${SUBJ}.fsf
fi



cd ${MAINOUTPUT}
if [ -d $OUTPUTREAL ]; then
	echo "This one is already done. Exiting script..."
else
	feat ${MAINOUTPUT}/2ndLvlFixed_${SUBJ}.fsf
	cd $OUTPUTREAL
	for j in `seq $NCOPES`; do
		COPE=cope${j}.feat
		cd $COPE
		rm -f filtered_func_data.nii.gz
		rm -f var_filtered_func_data.nii.gz
		rm -f stats/res4d.nii.gz
		cd ..
	done
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
