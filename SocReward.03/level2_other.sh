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
DENOISED=SUB_DENOISED
ISO=SUB_ISO

if [ "$MODEL" == "Model_1" ]; then
	NCOPES=28
elif [ "$MODEL" == "Model_2_Face" ] || [ "$MODEL" == "Model_2_Money" ]; then
	NCOPES=11
elif [ "$MODEL" == "Model_3" ]; then
	NCOPES=10
elif [ "$MODEL" == "Model_4_Face" ] || [ "$MODEL" == "Model_4_Money" ]; then
	NCOPES=2
fi



MAINDIR=${EXPERIMENT}/Analysis/FSL
SUBJECT_MAIN=${MAINDIR}/${SUBJ}
SUBJECT_MAIN2=${MAINDIR}/${SUBJ}

if [ $DENOISED -eq 1 -a $ISO -eq 0 ]; then
	SUBJDIR=${SUBJECT_MAIN}/Combo_Level2_denoised/$MODEL
	ATYPE=GLM3_denoised
elif [ $DENOISED -eq 0 -a $ISO -eq 0 ]; then
	SUBJDIR=${SUBJECT_MAIN}/Combo_Level2/$MODEL
	ATYPE=GLM3
elif [ $DENOISED -eq 1 -a $ISO -eq 1 ]; then
	SUBJDIR=${SUBJECT_MAIN}/Combo_Level2_denoised_4x4x4mm/$MODEL
	rm -rf ${SUBJECT_MAIN}/Combo_Level2_4x4x4mm_denoised
	ATYPE=GLM3_denoised_4x4x4mm
elif [ $DENOISED -eq 0 -a $ISO -eq 1 ]; then
	SUBJDIR=${SUBJECT_MAIN}/Combo_Level2_4x4x4mm/$MODEL
	ATYPE=GLM3_4x4x4mm
fi
mkdir -p $SUBJDIR

MAINOUTPUT=${SUBJDIR}
OUTPUT=${MAINOUTPUT}/${SUBJ}_level2
OUTPUTREAL=${OUTPUT}.gfeat
if [ $GO -eq 1 ]; then
	rm -rf $OUTPUTREAL
fi
if [ ! "$MODEL" == "Model_3" ]; then
	
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
	if [ ! $SUBJ -eq 35086 ]; then
		INPUT01=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run1.feat
		INPUT02=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run2.feat
		INPUT03=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run3.feat
		INPUT04=${SUBJECT_MAIN}/PassiveCued/$ATYPE/$MODEL/run1.feat
		INPUT05=${SUBJECT_MAIN}/PassiveCued/$ATYPE/$MODEL/run2.feat
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@NCOPES@'$NCOPES'@g' \
		-e 's@INPUT01@'$INPUT01'@g' \
		-e 's@INPUT02@'$INPUT02'@g' \
		-e 's@INPUT03@'$INPUT03'@g' \
		-e 's@INPUT04@'$INPUT04'@g' \
		-e 's@INPUT05@'$INPUT05'@g' \
		<level2_5inputs_other.fsf> ${MAINOUTPUT}/2ndLvlFixed_${SUBJ}.fsf
	else
		INPUT01=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run1.feat
		INPUT02=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run2.feat
		INPUT03=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run3.feat
		INPUT04=${SUBJECT_MAIN}/PassiveCued/$ATYPE/$MODEL/run1.feat
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@NCOPES@'$NCOPES'@g' \
		-e 's@INPUT01@'$INPUT01'@g' \
		-e 's@INPUT02@'$INPUT02'@g' \
		-e 's@INPUT03@'$INPUT03'@g' \
		-e 's@INPUT04@'$INPUT04'@g' \
		<level2_4inputs_other.fsf> ${MAINOUTPUT}/2ndLvlFixed_${SUBJ}.fsf
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
	
else
	
	for LIST in "F_constant 1 1" "F_linear 2 2" "M_constant 3 3" "M_linear 4 4" "F-M 5 7" "M-F 6 8"; do
		set -- $LIST
		COPENAME=$1
		PASSIVE_COPEN=$2
		CUED_COPEN=$3
	
		OUTPUT=${MAINOUTPUT}/${COPENAME}_level2
		OUTPUTREAL=${OUTPUT}.gfeat
		FILECHECK=${OUTPUTREAL}/cope1.feat/cluster_mask_zstat1.nii.gz
		if [ -e $FILECHECK ]; then
			echo "cope exists!"
		else
			rm -rf $OUTPUTREAL
		fi
		
		TEMPLATEDIR=${MAINDIR}/Templates
		cd $TEMPLATEDIR
		if [ ! $SUBJ -eq 35086 ]; then
			INPUT01=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run1.feat/stats/cope${PASSIVE_COPEN}.nii.gz
			INPUT02=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run2.feat/stats/cope${PASSIVE_COPEN}.nii.gz
			INPUT03=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run3.feat/stats/cope${PASSIVE_COPEN}.nii.gz
			INPUT04=${SUBJECT_MAIN}/PassiveCued/$ATYPE/$MODEL/run1.feat/stats/cope${CUED_COPEN}.nii.gz
			INPUT05=${SUBJECT_MAIN}/PassiveCued/$ATYPE/$MODEL/run2.feat/stats/cope${CUED_COPEN}.nii.gz
			sed -e 's@OUTPUT@'$OUTPUT'@g' \
			-e 's@NCOPES@'$NCOPES'@g' \
			-e 's@INPUT01@'$INPUT01'@g' \
			-e 's@INPUT02@'$INPUT02'@g' \
			-e 's@INPUT03@'$INPUT03'@g' \
			-e 's@INPUT04@'$INPUT04'@g' \
			-e 's@INPUT05@'$INPUT05'@g' \
			<level2_5inputs_cope.fsf> ${MAINOUTPUT}/2ndLvlFixed_${SUBJ}.fsf
		else
			INPUT01=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run1.feat/stats/cope${PASSIVE_COPEN}.nii.gz
			INPUT02=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run2.feat/stats/cope${PASSIVE_COPEN}.nii.gz
			INPUT03=${SUBJECT_MAIN}/Passive/$ATYPE/$MODEL/run3.feat/stats/cope${PASSIVE_COPEN}.nii.gz
			INPUT04=${SUBJECT_MAIN}/PassiveCued/$ATYPE/$MODEL/run1.feat/stats/cope${CUED_COPEN}.nii.gz
			sed -e 's@OUTPUT@'$OUTPUT'@g' \
			-e 's@NCOPES@'$NCOPES'@g' \
			-e 's@INPUT01@'$INPUT01'@g' \
			-e 's@INPUT02@'$INPUT02'@g' \
			-e 's@INPUT03@'$INPUT03'@g' \
			-e 's@INPUT04@'$INPUT04'@g' \
			<level2_4inputs_cope.fsf> ${MAINOUTPUT}/2ndLvlFixed_${SUBJ}.fsf
		fi
		
		cd ${MAINOUTPUT}
		if [ -d $OUTPUTREAL ]; then
			echo "This one is already done. Exiting script..."
		else
			feat ${MAINOUTPUT}/2ndLvlFixed_${SUBJ}.fsf
			cd $OUTPUTREAL
			COPE=cope1.feat
			cd $COPE
			rm -f filtered_func_data.nii.gz
			rm -f var_filtered_func_data.nii.gz
			rm -f stats/res4d.nii.gz
		fi
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
