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

SUBJ=SUB_SUBNUM_VAR
RUN=SUB_RUN_VAR
CONDITION=SUB_CONDITION_VAR
GO=SUB_GO_VAR

FSLDATADIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}/${SUBJ}_ica_6mm_ST/${SUBJ}_run${RUN}.ica
ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}
BASEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates/feat
DATA=${FSLDATADIR2}/crap_removed_data_v0.7.1.nii.gz

fslmaths $DATA -add 10 ${FSLDATADIR2}/test_file
if [ -e ${FSLDATADIR2}/test_file.nii.gz ]; then
	rm ${FSLDATADIR2}/test_file.nii.gz
else
	echo -e "$SUBJ\t$RUN" >> ${BASEDIR}/ERRORS_corrupt_data_${GO}.txt
fi

fslmaths $ANAT -add 10 ${FSLDATADIR2}/test_file
if [ -e ${FSLDATADIR2}/test_file.nii.gz ]; then
	rm ${FSLDATADIR2}/test_file.nii.gz
else
	echo -e "$SUBJ\t$RUN" >> ${BASEDIR}/ERRORS_corrupt_anat_${GO}.txt
fi


let "run2=${RUN}-1"
FSLEVDIR=${EXPERIMENT}/Analysis/FSL/EV_Logs_3-7-08_new/Model_1/${SUBJ}/Passive_new
ONESTAR=${FSLEVDIR}/Run${run2}/Run${run2}_OneStar_${SUBJ}.txt
TWOSTAR=${FSLEVDIR}/Run${run2}/Run${run2}_TwoStar_${SUBJ}.txt
THREESTAR=${FSLEVDIR}/Run${run2}/Run${run2}_ThreeStar_${SUBJ}.txt
FOURSTAR=${FSLEVDIR}/Run${run2}/Run${run2}_FourStar_${SUBJ}.txt
GAIN1=${FSLEVDIR}/Run${run2}/Run${run2}_GainOne_${SUBJ}.txt
LOSS1=${FSLEVDIR}/Run${run2}/Run${run2}_LossOne_${SUBJ}.txt
GAIN2=${FSLEVDIR}/Run${run2}/Run${run2}_GainTwo_${SUBJ}.txt
LOSS2=${FSLEVDIR}/Run${run2}/Run${run2}_LossTwo_${SUBJ}.txt
GAIN5=${FSLEVDIR}/Run${run2}/Run${run2}_GainFive_${SUBJ}.txt
LOSS5=${FSLEVDIR}/Run${run2}/Run${run2}_LossFive_${SUBJ}.txt


MOTOR=${FSLEVDIR}/Run${run2}/Run${run2}_MotorResponse_${SUBJ}.txt
if [ -e $MOTOR ]; then
	CONVOLVE=3
	SHAPE=3
else
	CONVOLVE=0
	SHAPE=10
fi


if [ ${CONDITION} == "Face" ]; then
	NCOPES=13
	MAINOUTPUT=${MAINDIR}/${SUBJ}_Model9_faces_6mm_ST
	mkdir -p ${MAINOUTPUT}
	OUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}
	if [ $RUN -eq 2 ] && [ $GO -eq 1 ]; then
		rm -r ${MAINOUTPUT}_BACKUP_Junk
	fi

	TEMPLATE=${TEMPLATEDIR}/reward_model_9_faces_template_NEW_con.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@ONESTAR@'$ONESTAR'@g' \
	-e 's@TWOSTAR@'$TWOSTAR'@g' \
	-e 's@THREESTAR@'$THREESTAR'@g' \
	-e 's@FOURSTAR@'$FOURSTAR'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@CONVOLVE@'$CONVOLVE'@g' \
	-e 's@SHAPE@'$SHAPE'@g' \
	-e 's@MOTOR@'$MOTOR'@g' \
	<${TEMPLATE}> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

elif [ ${CONDITION} == "Money" ]; then
	NCOPES=17
	MAINOUTPUT=${MAINDIR}/${SUBJ}_Model9_money_6mm_ST
	mkdir -p ${MAINOUTPUT}
	OUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}
	if [ $RUN -eq 2 ] && [ $GO -eq 1 ]; then
		rm -r ${MAINOUTPUT}_BACKUP_Junk
	fi

	TEMPLATE=${TEMPLATEDIR}/reward_model_9_money_template_NEW_con.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@GAIN5@'$GAIN5'@g' \
	-e 's@LOSS5@'$LOSS5'@g' \
	-e 's@GAIN2@'$GAIN2'@g' \
	-e 's@LOSS2@'$LOSS2'@g' \
	-e 's@GAIN1@'$GAIN1'@g' \
	-e 's@LOSS1@'$LOSS1'@g' \
	-e 's@CONVOLVE@'$CONVOLVE'@g' \
	-e 's@SHAPE@'$SHAPE'@g' \
	-e 's@MOTOR@'$MOTOR'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@DATA@'$DATA'@g' \
	<${TEMPLATE}> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

fi


if [ -d $OUTPUT.feat ]; then
       for C in `seq $NCOPES`; do
               CHECK_FILE=$OUTPUT.feat/cluster_mask_zstat${C}.nii.gz
               if [ -e $CHECK_FILE ]; then
                       COPE1_GOOD=1
               else
                       COPE1_GOOD=0
                       cd $EXPERIMENT
                       rm -rf $OUTPUT.feat
               fi
       done
fi



if [ $GO -eq 1 ]; then
	rm -r ${OUTPUT}.feat
fi

#run contrasts
# feat_model ${MAINOUTPUT}/FEAT_0${RUN}
# contrast_mgr ${OUTPUT}.feat/stats ${MAINOUTPUT}/FEAT_0${RUN}.con
# 
# for C in `seq $NCOPES`; do
# 	if [ ! -e ${OUTPUT}.feat/stats/cope${C}.nii.gz ]; then
# 		echo -e "$SUBJ\t$RUN" >> ${BASEDIR}/ERRORS_no_cope_${GO}.txt
# 	fi
# done

if [ -d $OUTPUT.feat ]; then
	echo "That one is already done!"
else
	feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
	rm -f ${OUTPUT}.feat/filtered_func_data.nii.gz
fi

OUTDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/December09_Logs_Go${GO}_${CONDITION}
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
