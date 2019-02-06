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


SUBJ=10156
RUN=1
SMOOTH=6
TASK=Framing
GO=99

FSLDIR=/usr/local/packages/fsl-4.1.4
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
source $FSLDIR/etc/fslconf/fsl.sh



SKIP=0
#-----------EXCEPTIONS FOR FUNCTIONAL DATA--------
#20091214_10179 (has anatomical data, but no functional data. what happened?)

#--changed time points starting on 10279. IRG cut to two runs. 
if [ $SUBJ -ge 10279 ] && [ $TASK == Risk ] && [ $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20091210_10168/20091210_10169 (restart; same subject; missing run3 of MID)
if [ $SUBJ -eq 10168 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20091208_10156 -- no resting state, only 1 of the 3 runs of the Risk Task
#20100119_10256 -- no resting state, only 1 of the 3 runs of the Risk Task
if [ $SUBJ -eq 10156 -o $SUBJ -eq 10256 ] && [ $TASK == Resting ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10156 -o $SUBJ -eq 10256 ] && [ $TASK == Risk -a $RUN -gt 1 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100120_10264 -- no resting state, missing 3rd run of the Risk Task
#20100120_10265 -- no resting state, missing 3rd run of the Risk Task
if [ $SUBJ -eq 10264 -o $SUBJ -eq 10265 ] && [ $TASK == Resting ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10264 -o $SUBJ -eq 10265 ] && [ $TASK == Risk -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100126_10280 -- no resting state
#20100127_10287 -- no resting state
#20100128_10294 -- no resting state
#20100310_10481 -- no resting state
if [ $SUBJ -eq 10280 -o $SUBJ -eq 10287 -o $SUBJ -eq 10294 -o $SUBJ -eq 10481 ] && [ $TASK == Resting ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100224_10387 -- no resting state, also missing framing run3 and all of the Risk task -- subject had to get out of the scanner
if [ $SUBJ -eq 10387 -a $TASK == Risk ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10387 -a $TASK == Resting ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10387 -a $TASK == Framing -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#20100212_10335 -- missing run3 of MID
#20100216_10350 -- missing run3 of MID
#20100216_10351 -- missing run3 of MID
if [ $SUBJ -eq 10335 -o $SUBJ -eq 10350 -o $SUBJ -eq 10351 ] && [ $TASK == MID -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100309_10471 -- only has MID runs 1 and 2. missing everything else. scanner fail.
if [ $SUBJ -eq 10471 ] && [ $TASK == Resting -o $TASK == Risk ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10471 ] && [ $TASK == MID -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/${TASK}/PreStats/Smooth_${SMOOTH}mm
mkdir -p ${MAINOUTPUT}


OUTPUTREAL=${MAINOUTPUT}/run${RUN}_NewCluster2.feat
FILE_TO_CHECK=${OUTPUTREAL}/new_filtered_func_data.nii.gz
if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUTREAL}
	sleep 20s
fi


ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
DATA=${SUBJDIR}/${TASK}/run${RUN}.nii.gz
OUTPUT=${MAINOUTPUT}/run${RUN}_NewCluster2
SO_FILE=${SUBJDIR}/${TASK}/so_run${RUN}.txt

# 
# if [ "$TASK" == "Framing" ]; then
# 	NVOLUMES=180
# elif [ "$TASK" == "Risk" ]; then
# 	NVOLUMES=180
# elif [ "$TASK" == "MID" ]; then
# 	NVOLUMES=212
# elif [ "$TASK" == "Resting" ]; then
# 	NVOLUMES=180
# fi

NVOLUMES=`fslnvols $DATA`

if [ $SKIP -eq 1 ]; then
	echo "skipping exceptions..."
	OUTDIR=${MAINDIR}/Logs/prestats/fsl_motion_outlier_skips/GO_${GO}
else
	NDISDAQS=6
	TEMPLATEDIR=${MAINDIR}/Templates
	cd ${TEMPLATEDIR}
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@SMOOTH@'$SMOOTH'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	-e 's@NDISDAQS@'$NDISDAQS'@g' \
	-e 's@SO_FILE@'$SO_FILE'@g' \
	<prestats_hugin_test.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
	
	cd ${MAINOUTPUT}
	if [ -d "$OUTPUTREAL" ]; then
		echo "That one is already done!"
	else
		
		$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
		#improve masked data for proper registrationss
		F_VALUE=0.4
		cd $OUTPUTREAL
		BETINPUT=mean_func.nii.gz
		BETOUTPUT=new_mean_func
		BETCMD="bet $BETINPUT $BETOUTPUT -f ${F_VALUE} -m"
		eval $BETCMD
		rm -rf stats
		mv new_mean_func_mask.nii.gz new_mask.nii.gz
		$FSLDIR/bin/fslmaths filtered_func_data.nii.gz -mas new_mask.nii.gz new_filtered_func_data
	
	fi
	
	
	
	cd ${MAINOUTPUT}
	if [ -d "$OUTPUTREAL" ]; then
		cd $OUTPUTREAL
		$FSLDIR/bin/fslmeants -i new_filtered_func_data.nii.gz -o wb_raw.txt -m new_mask.nii.gz
		if [ -e new_filtered_func_data.nii.gz ]; then
			rm -rf filtered_func_data.nii.gz
		fi
		rm -rf stats
	else
		echo "wtf... this file should be there"
	fi
	
	cp $OUTPUTREAL/mc/prefiltered_func_data_mcf.par $OUTPUTREAL/MOTIONconfoundevs.txt
	
	
	
	echo "LOOKING FOR BAD TIME POINTS ----------- HERE -----------"
	DATA=${SUBJDIR}/${TASK}/run${RUN}.nii.gz
	NDISDAQS=6
	if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
		echo "Exists: ${OUTPUTREAL}/bad_timepoints.txt"
		OUTDIR=${MAINDIR}/Logs/prestats/fsl_motion_outlier_SUCCESS/GO_${GO}
	else
		#fsl_motion_outliers ${DATA} ${NDISDAQS} ${OUTPUTREAL}/bad_timepoints.txt
		if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
			OUTDIR=${MAINDIR}/Logs/prestats/fsl_motion_outlier_SUCCESS/GO_${GO}
		else
			OUTDIR=${MAINDIR}/Logs/prestats/fsl_motion_outlier_FAIL/GO_${GO}
		fi
	fi
fi

mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out

RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
