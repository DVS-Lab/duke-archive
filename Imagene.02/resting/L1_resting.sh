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
# # $ -m ea
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
# # $ -M 
# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

SUBJ=SUB_SUBNUM_SUB
RUN=1
SMOOTH=6
TASK="Resting"
GO=SUB_GO_SUB
ROI=PCC1
STANDARD=SUB_STANDARD_SUB
TYPE=SUB_TYPE_SUB


SKIP=0
#-----------EXCEPTIONS FOR FUNCTIONAL DATA--------
#20091214_10179 (has anatomical data, but no functional data. what happened?)

#--changed time points starting on 10279. IRG cut to two runs. 
if [ $SUBJ -ge 10279 ] && [ "$TASK" == "Risk" ] && [ $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20091210_10168/20091210_10169 (restart; same subject; missing run3 of MID) -- everything is under 10168
if [ $SUBJ -eq 10168 ] && [ "$TASK" == "MID" ] && [ $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10169 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20091208_10156 -- no resting state, only 1 of the 3 runs of the Risk Task
#20100119_10256 -- no resting state, only 1 of the 3 runs of the Risk Task
if [ $SUBJ -eq 10156 -o $SUBJ -eq 10256 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10156 -o $SUBJ -eq 10256 ] && [ "$TASK" == "Risk" -a $RUN -gt 1 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100120_10264 -- no resting state, missing 3rd run of the Risk Task
#20100120_10265 -- no resting state, missing 3rd run of the Risk Task
if [ $SUBJ -eq 10264 -o $SUBJ -eq 10265 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10264 -o $SUBJ -eq 10265 ] && [ "$TASK" == "Risk" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100126_10280 -- no resting state
#20100127_10287 -- no resting state
#20100128_10294 -- no resting state
#20100310_10481 -- no resting state
if [ $SUBJ -eq 10280 -o $SUBJ -eq 10287 -o $SUBJ -eq 10294 -o $SUBJ -eq 10481 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100224_10387 -- no resting state, also missing framing run3 and all of the Risk task -- subject had to get out of the scanner
if [ $SUBJ -eq 10387 -a "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10387 -a "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10387 -a "$TASK" == "Framing" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#20100212_10335 -- missing run3 of MID
#20100216_10350 -- missing run3 of MID
#20100216_10351 -- missing run3 of MID
if [ $SUBJ -eq 10335 -o $SUBJ -eq 10350 -o $SUBJ -eq 10351 ] && [ "$TASK" == "MID" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100309_10471 -- only has MID runs 1 and 2. missing everything else. scanner fail.
if [ $SUBJ -eq 10471 ] && [ "$TASK" == "Resting" -o "$TASK" == "Risk" -o "$TASK" == "Framing" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10471 ] && [ "$TASK" == "MID" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100330_10602: no resting state
if [ $SUBJ -eq 10602 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100413_10699: he didn't have any of McKell's task, but he still had resting state in run004_08
if [ $SUBJ -eq 10699 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#--------end exceptions list-------



MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=$EXPERIMENT/Analysis/Resting_Default-Network/${SUBJ}
if [ $SKIP -eq 1 ]; then
	echo "not making dirs for exceptions..."
else
	mkdir -p ${MAINOUTPUT}
fi

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUTREAL}
fi

ANAT=$EXPERIMENT/Analysis/TaskData/${SUBJ}/${SUBJ}_anat_brain.nii.gz


#data location and other variables
if [ $TYPE -eq 1 ]; then
	FSLDATADIR=$EXPERIMENT/Analysis/TaskData/${SUBJ}/Resting/lpfilt_MELODIC/Smooth_6mm
	DATA=${FSLDATADIR}/run1.ica/filtered_func_data.nii.gz
	OUTPUT=${MAINOUTPUT}/${SUBJ}_${ROI}_lpfilt
elif [ $TYPE -eq 2 ]; then
	FSLDATADIR=$EXPERIMENT/Analysis/TaskData/${SUBJ}/Resting/MELODIC/Smooth_6mm
	DATA=${FSLDATADIR}/run1.ica/normal_denoised_data.nii.gz
	OUTPUT=${MAINOUTPUT}/${SUBJ}_${ROI}_ICAnormal
elif [ $TYPE -eq 3 ]; then
	FSLDATADIR=$EXPERIMENT/Analysis/TaskData/${SUBJ}/Resting/MELODIC/Smooth_6mm
	DATA=${FSLDATADIR}/run1.ica/special_denoised_data.nii.gz
	OUTPUT=${MAINOUTPUT}/${SUBJ}_${ROI}_ICAspecial
elif [ $TYPE -eq 4 ]; then
	FSLDATADIR=$EXPERIMENT/Analysis/TaskData/${SUBJ}/Resting/MELODIC/Smooth_6mm
	DATA=${FSLDATADIR}/run1.ica/filtered_func_data.nii.gz
	OUTPUT=${MAINOUTPUT}/${SUBJ}_${ROI}
fi

if [ "$STANDARD" == "new" ]; then
	STANDARD_IMAGE=$EXPERIMENT/Analysis/Resting_Default-Network/mni_3p75_3p75_3p80_defaultO_FINAL
	OUTPUT=${MAINOUTPUT}/${SUBJ}_${ROI}_3.75x3.75x3.80mm
else
	STANDARD_IMAGE=$EXPERIMENT/Analysis/Resting_Default-Network/MNI152_T1_2mm_brain
	#OUTPUT=${MAINOUTPUT}/${SUBJ}_${ROI}
fi

OUTDIR=$EXPERIMENT/Analysis/Resting_Default-Network/Logs/worked
mkdir -p $OUTDIR



if [ ! -e ${OUTPUT}.feat/cluster_mask_zstat4.nii.gz ]; then 
	rm -rf ${OUTPUT}.feat
fi

#make regressors
GLOBAL=${FSLDATADIR}/run1.ica/global_filtered_${TYPE}.txt
LOCAL=${FSLDATADIR}/run1.ica/${ROI}_local_filtered_${TYPE}.txt
REF=${FSLDATADIR}/run1.ica/reg/example_func.nii.gz
MATRIX=${FSLDATADIR}/run1.ica/reg/standard2example_func.mat
FLIRTOUTPUT=${FSLDATADIR}/run1.ica/${ROI}_native_${TYPE}
FLIRTINPUT=$EXPERIMENT/Analysis/Resting_Default-Network/ROIs/${ROI}.nii.gz
WB=${FSLDATADIR}/run1.ica/mask.nii.gz

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.feat
	rm -rf ${LOCAL}
	rm -rf ${FLIRTOUTPUT}
fi

if [ ! -e $LOCAL ]; then
	flirt -in ${FLIRTINPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${FLIRTOUTPUT}
	fslmaths ${FLIRTOUTPUT} -thr 0.2 -bin ${FLIRTOUTPUT}
fi
fslmeants -i ${DATA} -o ${LOCAL} -m ${FLIRTOUTPUT}
fslmeants -i ${DATA} -o ${GLOBAL} -m ${WB}


if [ "$STANDARD" == "new" ]; then
	STANDARD_IMAGE=$EXPERIMENT/Analysis/Resting_Default-Network/mni_3p75_3p75_3p80_defaultO_FINAL
else
	STANDARD_IMAGE=$EXPERIMENT/Analysis/Resting_Default-Network/MNI152_T1_2mm_brain
fi


NVOLUMES=`fslnvols $DATA`
if [ $SKIP -eq 1 ]; then
	echo "skipping exceptions..."
	OUTDIR=$EXPERIMENT/Analysis/Resting_Default-Network/Logs/failed
else
	#run analyses
	CONFOUNDEVS=${FSLDATADIR}/run1.ica/bad_timepoints.txt
	if [ -e $CONFOUNDEVS ]; then
		TEMPLATE=$EXPERIMENT/Analysis/Resting_Default-Network/Templates/resting_Global_ortho_badTRs.fsf
		sed -e 's@DATA@'$DATA'@g' \
		-e 's@ANAT@'$ANAT'@g' \
		-e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@GLOBAL@'$GLOBAL'@g' \
		-e 's@LOCAL@'$LOCAL'@g' \
		-e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
		-e 's@NVOLUMES@'$NVOLUMES'@g' \
		-e 's@STANDARD_IMAGE@'$STANDARD_IMAGE'@g' \
		<$TEMPLATE> ${MAINOUTPUT}/${SUBJ}_model${ROI}_${STANDARD}_${TYPE}.fsf
	else
		TEMPLATE=$EXPERIMENT/Analysis/Resting_Default-Network/Templates/resting_Global_ortho.fsf
		sed -e 's@DATA@'$DATA'@g' \
		-e 's@ANAT@'$ANAT'@g' \
		-e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@GLOBAL@'$GLOBAL'@g' \
		-e 's@NVOLUMES@'$NVOLUMES'@g' \
		-e 's@LOCAL@'$LOCAL'@g' \
		-e 's@STANDARD_IMAGE@'$STANDARD_IMAGE'@g' \
		<$TEMPLATE> ${MAINOUTPUT}/${SUBJ}_model${ROI}_${STANDARD}_${TYPE}.fsf
	fi
	
	#run the newly created fsf files
	if [ -d $OUTPUT.feat ]; then
		echo "$OUTPUT.feat exists! skipping to the next one"
	else
		$FSLDIR/bin/feat ${MAINOUTPUT}/${SUBJ}_model${ROI}_${STANDARD}_${TYPE}.fsf
	fi
fi


# clean up unwanted files
cd ${OUTPUT}.feat
rm -f filtered_func_data.nii.gz
rm -f stats/res4d.nii.gz


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	
rm -rf $HOME/$JOB_NAME.$JOB_ID.out

RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
