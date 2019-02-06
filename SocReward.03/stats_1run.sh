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
RUN=SUB_RUN
MODEL=SUB_MODEL
GO=SUB_GO
DENOISED=SUB_DENOISED


if [ $RUN -gt 3 ]; then
	TASK=PassiveCued
	let RUN=$RUN-3
	NVOLUMES=291
else
	TASK=Passive
	NVOLUMES=227
fi

if [ $SUBJ -eq 35086 ] && [ $RUN -eq 2 ] && [ "$TASK" == "PassiveCued" ]; then
	exit
fi
STANDARD=${EXPERIMENT}/Analysis/FSL/standard_4mm.nii.gz
if [ $MODEL -eq 2 ] || [ $MODEL -eq 4 ]; then
	for CONDITION in "Face" "Money"; do
	
		MAINDIR=${EXPERIMENT}/Analysis/FSL
		SUBJDIR=${MAINDIR}/${SUBJ}

		if [ $DENOISED -eq 1 ]; then
			MAINOUTPUT=${SUBJDIR}/${TASK}/GLM3_denoised_4x4x4mm/Model_${MODEL}_$CONDITION
			OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
			mkdir -p ${MAINOUTPUT}
			ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
			DATA=${SUBJDIR}/${TASK}/MELODIC/Smooth_6mm/run${RUN}.ica/denoised_data.nii.gz
			OUTPUT=${MAINOUTPUT}/run${RUN}
		else
			MAINOUTPUT=${SUBJDIR}/${TASK}/GLM3_4x4x4mm/Model_${MODEL}_$CONDITION
			OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
			mkdir -p ${MAINOUTPUT}
			ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
			DATA=${SUBJDIR}/${TASK}/MELODIC/Smooth_6mm/run${RUN}.ica/filtered_func_data.nii.gz
			OUTPUT=${MAINOUTPUT}/run${RUN}
		fi

		#set up models
		if [ $MODEL -eq 2 ]; then
			TEMPLATEDIR=${MAINDIR}/Templates2
			EV_DIR=${EXPERIMENT}/Analysis/Behavior/EV_Files2/basic_regressors/$TASK/$SUBJ
			cd ${TEMPLATEDIR}
			if [ "$CONDITION" == "Face" ]; then
				REGRESSOR1=${EV_DIR}/Run${RUN}_1-Star_$SUBJ.txt
				REGRESSOR2=${EV_DIR}/Run${RUN}_2-Star_$SUBJ.txt
				REGRESSOR3=${EV_DIR}/Run${RUN}_3-Star_$SUBJ.txt
				REGRESSOR4=${EV_DIR}/Run${RUN}_4-Star_$SUBJ.txt
				CUE=${EV_DIR}/Run${RUN}_PicCue_$SUBJ.txt
			elif [ "$CONDITION" == "Money" ]; then
				REGRESSOR1=${EV_DIR}/Run${RUN}_lose5_$SUBJ.txt
				REGRESSOR2=${EV_DIR}/Run${RUN}_lose1_$SUBJ.txt
				REGRESSOR3=${EV_DIR}/Run${RUN}_gain1_$SUBJ.txt
				REGRESSOR4=${EV_DIR}/Run${RUN}_gain5_$SUBJ.txt
				CUE=${EV_DIR}/Run${RUN}_MoneyCue_$SUBJ.txt
			else
				echo "condition error"
			fi
			MOTOR=${EV_DIR}/Run${RUN}_MotorResponse_$SUBJ.txt
			if [ $TASK == "PassiveCued" ]; then
				if [ ! -e $MOTOR ]; then
					sed -e 's@OUTPUT@'$OUTPUT'@g' \
					-e 's@ANAT@'$ANAT'@g' \
					-e 's@DATA@'$DATA'@g' \
					-e 's@NVOLUMES@'$NVOLUMES'@g' \
					-e 's@REGRESSOR1@'$REGRESSOR1'@g' \
					-e 's@REGRESSOR2@'$REGRESSOR2'@g' \
					-e 's@REGRESSOR3@'$REGRESSOR3'@g' \
					-e 's@REGRESSOR4@'$REGRESSOR4'@g' \
					-e 's@STANDARD@'$STANDARD'@g' \
					-e 's@CUE@'$CUE'@g' \
					<split_PassiveCued_noMotor.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
				else
					sed -e 's@OUTPUT@'$OUTPUT'@g' \
					-e 's@ANAT@'$ANAT'@g' \
					-e 's@DATA@'$DATA'@g' \
					-e 's@NVOLUMES@'$NVOLUMES'@g' \
					-e 's@REGRESSOR1@'$REGRESSOR1'@g' \
					-e 's@REGRESSOR2@'$REGRESSOR2'@g' \
					-e 's@REGRESSOR3@'$REGRESSOR3'@g' \
					-e 's@REGRESSOR4@'$REGRESSOR4'@g' \
					-e 's@STANDARD@'$STANDARD'@g' \
					-e 's@CUE@'$CUE'@g' \
					-e 's@MOTOR@'$MOTOR'@g' \
					<split_PassiveCued_withMotor.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
				fi
			else
				if [ ! -e $MOTOR ]; then
					sed -e 's@OUTPUT@'$OUTPUT'@g' \
					-e 's@ANAT@'$ANAT'@g' \
					-e 's@DATA@'$DATA'@g' \
					-e 's@NVOLUMES@'$NVOLUMES'@g' \
					-e 's@REGRESSOR1@'$REGRESSOR1'@g' \
					-e 's@REGRESSOR2@'$REGRESSOR2'@g' \
					-e 's@REGRESSOR3@'$REGRESSOR3'@g' \
					-e 's@REGRESSOR4@'$REGRESSOR4'@g' \
					-e 's@STANDARD@'$STANDARD'@g' \
					<split_Passive_noMotor.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
				else
					sed -e 's@OUTPUT@'$OUTPUT'@g' \
					-e 's@ANAT@'$ANAT'@g' \
					-e 's@DATA@'$DATA'@g' \
					-e 's@NVOLUMES@'$NVOLUMES'@g' \
					-e 's@REGRESSOR1@'$REGRESSOR1'@g' \
					-e 's@REGRESSOR2@'$REGRESSOR2'@g' \
					-e 's@REGRESSOR3@'$REGRESSOR3'@g' \
					-e 's@REGRESSOR4@'$REGRESSOR4'@g' \
					-e 's@STANDARD@'$STANDARD'@g' \
					-e 's@MOTOR@'$MOTOR'@g' \
					<split_Passive_withMotor.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
				fi
			fi
		else
			TEMPLATEDIR=${MAINDIR}/Templates2
			EV_DIR=${EXPERIMENT}/Analysis/Behavior/EV_Files2/parametric_regressors/$TASK/$SUBJ
			cd ${TEMPLATEDIR}
			if [ "$CONDITION" == "Face" ]; then
				CONSTANT=${EV_DIR}/Run${RUN}_constantFace_$SUBJ.txt
				LINEAR=${EV_DIR}/Run${RUN}_linearFace_$SUBJ.txt
				CUE=${EV_DIR}/Run${RUN}_PicCue_$SUBJ.txt
			elif [ "$CONDITION" == "Money" ]; then
				CONSTANT=${EV_DIR}/Run${RUN}_constantMoney_$SUBJ.txt
				LINEAR=${EV_DIR}/Run${RUN}_linearMoney_$SUBJ.txt
				CUE=${EV_DIR}/Run${RUN}_MoneyCue_$SUBJ.txt
			else
				echo "condition error"
			fi
			MOTOR=${EV_DIR}/Run${RUN}_MotorResponse_$SUBJ.txt
			if [ $TASK == "PassiveCued" ]; then
				if [ ! -e $MOTOR ]; then
					sed -e 's@OUTPUT@'$OUTPUT'@g' \
					-e 's@ANAT@'$ANAT'@g' \
					-e 's@DATA@'$DATA'@g' \
					-e 's@NVOLUMES@'$NVOLUMES'@g' \
					-e 's@CONSTANT@'$CONSTANT'@g' \
					-e 's@LINEAR@'$LINEAR'@g' \
					-e 's@CUE@'$CUE'@g' \
					-e 's@STANDARD@'$STANDARD'@g' \
					<split_PassiveCued_noMotor_parametric.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
				else
					sed -e 's@OUTPUT@'$OUTPUT'@g' \
					-e 's@ANAT@'$ANAT'@g' \
					-e 's@DATA@'$DATA'@g' \
					-e 's@NVOLUMES@'$NVOLUMES'@g' \
					-e 's@CONSTANT@'$CONSTANT'@g' \
					-e 's@LINEAR@'$LINEAR'@g' \
					-e 's@CUE@'$CUE'@g' \
					-e 's@MOTOR@'$MOTOR'@g' \
					-e 's@STANDARD@'$STANDARD'@g' \
					<split_PassiveCued_withMotor_parametric.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
				fi
			else
				if [ ! -e $MOTOR ]; then
					sed -e 's@OUTPUT@'$OUTPUT'@g' \
					-e 's@ANAT@'$ANAT'@g' \
					-e 's@DATA@'$DATA'@g' \
					-e 's@NVOLUMES@'$NVOLUMES'@g' \
					-e 's@CONSTANT@'$CONSTANT'@g' \
					-e 's@LINEAR@'$LINEAR'@g' \
					-e 's@STANDARD@'$STANDARD'@g' \
					<split_Passive_noMotor_parametric.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
				else
					sed -e 's@OUTPUT@'$OUTPUT'@g' \
					-e 's@ANAT@'$ANAT'@g' \
					-e 's@DATA@'$DATA'@g' \
					-e 's@NVOLUMES@'$NVOLUMES'@g' \
					-e 's@CONSTANT@'$CONSTANT'@g' \
					-e 's@LINEAR@'$LINEAR'@g' \
					-e 's@MOTOR@'$MOTOR'@g' \
					-e 's@STANDARD@'$STANDARD'@g' \
					<split_Passive_withMotor_parametric.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
				fi
			fi
		fi
		
		if [ $GO -eq 1 ]; then
			rm -rf ${OUTPUTREAL}
		fi
		cd ${MAINOUTPUT}
		if [ -d "$OUTPUTREAL" ]; then
			echo "That one is already done!"
		else
			feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			cd $OUTPUTREAL
			rm -rf filtered_func_data.nii.gz
			rm -rf stats/res4d.nii.gz
		fi
	done
else

	MAINDIR=${EXPERIMENT}/Analysis/FSL
	SUBJDIR=${MAINDIR}/${SUBJ}

	if [ $DENOISED -eq 1 ]; then
		MAINOUTPUT=${SUBJDIR}/${TASK}/GLM3_denoised_4x4x4mm/Model_${MODEL}
		OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
		mkdir -p ${MAINOUTPUT}
		ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
		DATA=${SUBJDIR}/${TASK}/MELODIC/Smooth_6mm/run${RUN}.ica/denoised_data.nii.gz
		OUTPUT=${MAINOUTPUT}/run${RUN}
	else
		MAINOUTPUT=${SUBJDIR}/${TASK}/GLM3_4x4x4mm/Model_${MODEL}
		OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
		mkdir -p ${MAINOUTPUT}
		ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
		DATA=${SUBJDIR}/${TASK}/MELODIC/Smooth_6mm/run${RUN}.ica/filtered_func_data.nii.gz
		OUTPUT=${MAINOUTPUT}/run${RUN}
	fi


	if [ $GO -eq 1 ]; then
		rm -rf ${OUTPUTREAL}
	fi


	if [ $MODEL -eq 1 ]; then	
		#set up models
		TEMPLATEDIR=${MAINDIR}/Templates2
		EV_DIR=${EXPERIMENT}/Analysis/Behavior/EV_Files2/basic_regressors/$TASK/$SUBJ
		cd ${TEMPLATEDIR}
		ONESTAR=${EV_DIR}/Run${RUN}_1-Star_$SUBJ.txt
		TWOSTAR=${EV_DIR}/Run${RUN}_2-Star_$SUBJ.txt
		THREESTAR=${EV_DIR}/Run${RUN}_3-Star_$SUBJ.txt
		FOURSTAR=${EV_DIR}/Run${RUN}_4-Star_$SUBJ.txt
		LOSE5=${EV_DIR}/Run${RUN}_lose5_$SUBJ.txt
		LOSE1=${EV_DIR}/Run${RUN}_lose1_$SUBJ.txt
		GAIN1=${EV_DIR}/Run${RUN}_gain1_$SUBJ.txt
		GAIN5=${EV_DIR}/Run${RUN}_gain5_$SUBJ.txt
		MOTOR=${EV_DIR}/Run${RUN}_MotorResponse_$SUBJ.txt
		FACECUE=${EV_DIR}/Run${RUN}_PicCue_$SUBJ.txt
		MONEYCUE=${EV_DIR}/Run${RUN}_MoneyCue_$SUBJ.txt
		if [ "$TASK" == "Passive" ]; then
			if [ ! -e $MOTOR ]; then
				sed -e 's@OUTPUT@'$OUTPUT'@g' \
				-e 's@ANAT@'$ANAT'@g' \
				-e 's@DATA@'$DATA'@g' \
				-e 's@NVOLUMES@'$NVOLUMES'@g' \
				-e 's@ONESTAR@'$ONESTAR'@g' \
				-e 's@TWOSTAR@'$TWOSTAR'@g' \
				-e 's@THREESTAR@'$THREESTAR'@g' \
				-e 's@FOURSTAR@'$FOURSTAR'@g' \
				-e 's@LOSE5@'$LOSE5'@g' \
				-e 's@LOSE1@'$LOSE1'@g' \
				-e 's@GAIN1@'$GAIN1'@g' \
				-e 's@GAIN5@'$GAIN5'@g' \
				-e 's@STANDARD@'$STANDARD'@g' \
				<Passive_noMotor.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			else
				sed -e 's@OUTPUT@'$OUTPUT'@g' \
				-e 's@ANAT@'$ANAT'@g' \
				-e 's@DATA@'$DATA'@g' \
				-e 's@NVOLUMES@'$NVOLUMES'@g' \
				-e 's@ONESTAR@'$ONESTAR'@g' \
				-e 's@TWOSTAR@'$TWOSTAR'@g' \
				-e 's@THREESTAR@'$THREESTAR'@g' \
				-e 's@FOURSTAR@'$FOURSTAR'@g' \
				-e 's@LOSE5@'$LOSE5'@g' \
				-e 's@LOSE1@'$LOSE1'@g' \
				-e 's@GAIN1@'$GAIN1'@g' \
				-e 's@GAIN5@'$GAIN5'@g' \
				-e 's@MOTOR@'$MOTOR'@g' \
				-e 's@STANDARD@'$STANDARD'@g' \
				<Passive_withMotor.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			fi
		else
			if [ ! -e $MOTOR ]; then
				sed -e 's@OUTPUT@'$OUTPUT'@g' \
				-e 's@ANAT@'$ANAT'@g' \
				-e 's@DATA@'$DATA'@g' \
				-e 's@NVOLUMES@'$NVOLUMES'@g' \
				-e 's@ONESTAR@'$ONESTAR'@g' \
				-e 's@TWOSTAR@'$TWOSTAR'@g' \
				-e 's@THREESTAR@'$THREESTAR'@g' \
				-e 's@FOURSTAR@'$FOURSTAR'@g' \
				-e 's@LOSE5@'$LOSE5'@g' \
				-e 's@LOSE1@'$LOSE1'@g' \
				-e 's@GAIN1@'$GAIN1'@g' \
				-e 's@GAIN5@'$GAIN5'@g' \
				-e 's@FACECUE@'$FACECUE'@g' \
				-e 's@MONEYCUE@'$MONEYCUE'@g' \
				-e 's@STANDARD@'$STANDARD'@g' \
				<PassiveCued_noMotor.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			else
				sed -e 's@OUTPUT@'$OUTPUT'@g' \
				-e 's@ANAT@'$ANAT'@g' \
				-e 's@DATA@'$DATA'@g' \
				-e 's@NVOLUMES@'$NVOLUMES'@g' \
				-e 's@ONESTAR@'$ONESTAR'@g' \
				-e 's@TWOSTAR@'$TWOSTAR'@g' \
				-e 's@THREESTAR@'$THREESTAR'@g' \
				-e 's@FOURSTAR@'$FOURSTAR'@g' \
				-e 's@LOSE5@'$LOSE5'@g' \
				-e 's@LOSE1@'$LOSE1'@g' \
				-e 's@GAIN1@'$GAIN1'@g' \
				-e 's@GAIN5@'$GAIN5'@g' \
				-e 's@MOTOR@'$MOTOR'@g' \
				-e 's@FACECUE@'$FACECUE'@g' \
				-e 's@MONEYCUE@'$MONEYCUE'@g' \
				-e 's@STANDARD@'$STANDARD'@g' \
				<PassiveCued_withMotor.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			fi
		fi
	elif [ $MODEL -eq 3 ]; then
		TEMPLATEDIR=${MAINDIR}/Templates2
		EV_DIR=${EXPERIMENT}/Analysis/Behavior/EV_Files2/parametric_regressors/$TASK/$SUBJ
		cd ${TEMPLATEDIR}

		FACECONSTANT=${EV_DIR}/Run${RUN}_constantFace_$SUBJ.txt
		FACELINEAR=${EV_DIR}/Run${RUN}_linearFace_$SUBJ.txt
		FACECUE=${EV_DIR}/Run${RUN}_PicCue_$SUBJ.txt
		MONEYCONSTANT=${EV_DIR}/Run${RUN}_constantMoney_$SUBJ.txt
		MONEYLINEAR=${EV_DIR}/Run${RUN}_linearMoney_$SUBJ.txt
		MONEYCUE=${EV_DIR}/Run${RUN}_MoneyCue_$SUBJ.txt
		MOTOR=${EV_DIR}/Run${RUN}_MotorResponse_$SUBJ.txt

		if [ "$TASK" == "Passive" ]; then
			if [ ! -e $MOTOR ]; then
				sed -e 's@OUTPUT@'$OUTPUT'@g' \
				-e 's@ANAT@'$ANAT'@g' \
				-e 's@DATA@'$DATA'@g' \
				-e 's@NVOLUMES@'$NVOLUMES'@g' \
				-e 's@FACECONSTANT@'$FACECONSTANT'@g' \
				-e 's@FACELINEAR@'$FACELINEAR'@g' \
				-e 's@MONEYLINEAR@'$MONEYLINEAR'@g' \
				-e 's@MONEYCONSTANT@'$MONEYCONSTANT'@g' \
				-e 's@STANDARD@'$STANDARD'@g' \
				<Passive_noMotor_parametric.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			else
				sed -e 's@OUTPUT@'$OUTPUT'@g' \
				-e 's@ANAT@'$ANAT'@g' \
				-e 's@DATA@'$DATA'@g' \
				-e 's@NVOLUMES@'$NVOLUMES'@g' \
				-e 's@FACECONSTANT@'$FACECONSTANT'@g' \
				-e 's@FACELINEAR@'$FACELINEAR'@g' \
				-e 's@MONEYLINEAR@'$MONEYLINEAR'@g' \
				-e 's@MONEYCONSTANT@'$MONEYCONSTANT'@g' \
				-e 's@MOTOR@'$MOTOR'@g' \
				-e 's@STANDARD@'$STANDARD'@g' \
				<Passive_withMotor_parametric.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			fi
		else
			if [ ! -e $MOTOR ]; then
				sed -e 's@OUTPUT@'$OUTPUT'@g' \
				-e 's@ANAT@'$ANAT'@g' \
				-e 's@DATA@'$DATA'@g' \
				-e 's@NVOLUMES@'$NVOLUMES'@g' \
				-e 's@FACECONSTANT@'$FACECONSTANT'@g' \
				-e 's@FACELINEAR@'$FACELINEAR'@g' \
				-e 's@MONEYLINEAR@'$MONEYLINEAR'@g' \
				-e 's@MONEYCONSTANT@'$MONEYCONSTANT'@g' \
				-e 's@FACECUE@'$FACECUE'@g' \
				-e 's@MONEYCUE@'$MONEYCUE'@g' \
				-e 's@STANDARD@'$STANDARD'@g' \
				<PassiveCued_noMotor_parametric.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			else
				sed -e 's@OUTPUT@'$OUTPUT'@g' \
				-e 's@ANAT@'$ANAT'@g' \
				-e 's@DATA@'$DATA'@g' \
				-e 's@NVOLUMES@'$NVOLUMES'@g' \
				-e 's@FACECONSTANT@'$FACECONSTANT'@g' \
				-e 's@FACELINEAR@'$FACELINEAR'@g' \
				-e 's@MONEYLINEAR@'$MONEYLINEAR'@g' \
				-e 's@MONEYCONSTANT@'$MONEYCONSTANT'@g' \
				-e 's@FACECUE@'$FACECUE'@g' \
				-e 's@MONEYCUE@'$MONEYCUE'@g' \
				-e 's@MOTOR@'$MOTOR'@g' \
				-e 's@STANDARD@'$STANDARD'@g' \
				<PassiveCued_withMotor_parametric.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
			fi
		fi
	fi
fi


cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
	cd $OUTPUTREAL
	rm -rf filtered_func_data.nii.gz
	rm -rf stats/res4d.nii.gz
fi

OUTDIR=${MAINOUTPUT}/Logs
mkdir -p $OUTDIR

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
