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


FSLDIR=/usr/local/packages/fsl-4.1.8
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH


SUBJ=SUB_SUBNUM_SUB
RUN=SUB_RUN_SUB
SMOOTH=SUB_SMOOTH_SUB
TASK=SUB_TASK_SUB
GO=SUB_GO_SUB
FNIRT=SUB_FNIRT_SUB


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

#new exceptions (9/28/10)
#----new exceptions: june, july, august, september

#20100818_11272/20100810_11235: no resting
if [ $SUBJ -eq 11272 -o $SUBJ -eq 11235 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100811_11244 -- only has MID runs 1. missing everything else. BIAC fail (server = full).
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "MID" ] && [ $RUN -gt 1 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Framing" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#20100811_11245 -- missing MID1 and MID2, and resting. BIAC fail (server = full).
if [ $SUBJ -eq 11245 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11245 ] && [ "$TASK" == "MID" -a $RUN -lt 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20110106_12082: no risk
if [ $SUBJ -eq 12082 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20110128_12193 -- nothing after MID2. just two runs of data. fail.
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "MID" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Framing" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi



#20110311_12411 -- no resting
if [ $SUBJ -eq 12411 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#20110401_12580 -- only MID and resting state
if [ $SUBJ -eq 12580 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12580 ] && [ "$TASK" == "Framing" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20110502_12815/20110512_12875: no resting
if [ $SUBJ -eq 12815 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12875 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#12893/13011 : no resting
if [ $SUBJ -eq 12893 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 13011 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#11196: no resting, no GC3, no IRG2 (CHECK FAT SAT!)
if [ $SUBJ -eq 11196 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11196 ] && [ "$TASK" == "Risk" -a $RUN -eq 2 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11196 ] && [ "$TASK" == "Framing" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#11210: no MID3, no GC3 (CHECK FAT SAT!)
if [ $SUBJ -eq 11210 ] && [ "$TASK" == "MID" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11210 ] && [ "$TASK" == "Framing" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#11212: no resting or IRG2 (CHECK FAT SAT!)
if [ $SUBJ -eq 11212 ] && [ "$TASK" == "Risk" -a $RUN -eq 2 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11212 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#10783: no resting -- petty: confirmed data lost 5/17/10 (scanner fail)
if [ $SUBJ -eq 10783 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
#10783: no risk run2 -- petty: confirmed data lost 5/17/10 (scanner fail)
if [ $SUBJ -eq 10783 ] && [ "$TASK" == "Risk" -a $RUN -eq 2 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi



#--------end exceptions list-------


MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
if [ $FNIRT -eq 1 ]; then
	MAINOUTPUT=${SUBJDIR}/${TASK}/MELODIC_FNIRT/Smooth_${SMOOTH}mm
else
	MAINOUTPUT=${SUBJDIR}/${TASK}/MELODIC_FLIRT/Smooth_${SMOOTH}mm
fi

if [ $SKIP -eq 1 ]; then
	echo "not making dirs for exceptions..."
else
	mkdir -p ${MAINOUTPUT}
fi

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.ica
FILE_TO_CHECK=${OUTPUTREAL}/filtered_func_data.nii.gz
if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUTREAL}
fi
if [ ! -e $FILE_TO_CHECK ]; then
	rm -rf ${OUTPUTREAL}
fi

ANAT=${SUBJDIR}/${SUBJ}_anat_brain
DATA=${SUBJDIR}/${TASK}/run${RUN}
OUTPUT=${MAINOUTPUT}/run${RUN}
SO_FILE=${SUBJDIR}/${TASK}/so_run${RUN}.txt

NVOLUMES=`fslnvols $DATA`
NDISDAQS=8
STANDARD=$MAINDIR/MNI_diffeo_brain

if [ $SKIP -eq 1 ]; then
	echo "skipping exceptions..."
	OUTDIR=${MAINDIR}/Logs/ica_july2011/fsl_motion_outlier_skips/GO_${GO}
else
	TEMPLATEDIR=${MAINDIR}/Templates
	cd ${TEMPLATEDIR}
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@SMOOTH@'$SMOOTH'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	-e 's@NDISDAQS@'$NDISDAQS'@g' \
	-e 's@SO_FILE@'$SO_FILE'@g' \
	-e 's@DOFNIRT@'$FNIRT'@g' \
	-e 's@STANDARD@'$STANDARD'@g' \
	<melodic_IG2.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
	
	
	OUTPUTREAL=${MAINOUTPUT}/run${RUN}.ica
	cd ${MAINOUTPUT}
	if [ -d "$OUTPUTREAL" ]; then
		cd $OUTPUTREAL
		$FSLDIR/bin/fslmeants -i filtered_func_data.nii.gz -o wb_raw.txt -m mask.nii.gz
		rm -rf stats
	else
		echo "wtf... this file should be there"
	fi
	
	cp $OUTPUTREAL/mc/prefiltered_func_data_mcf.par $OUTPUTREAL/MOTIONconfoundevs.txt
	
	cd ${MAINOUTPUT}
	if [ -d "$OUTPUTREAL" ]; then
		echo "That one is already done!"
	else
		$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
	fi


	if [ $FNIRT -eq 1 ]; then
		echo "not deleting filtered_func file"
	else
		echo "deleting filtered_func file to avoid duplication. look in FNIRT directory for data."
		rm -rf $OUTPUTREAL/filtered_func_data.nii.gz
	fi

	
	echo "LOOKING FOR BAD TIME POINTS ----------- HERE -----------"
	if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
		echo "Exists: ${OUTPUTREAL}/bad_timepoints.txt"
		OUTDIR=${MAINDIR}/Logs/ica_july2011/fsl_motion_outlier_SUCCESS/GO_${GO}
	else
		fsl_motion_outliers ${DATA} ${NDISDAQS} ${OUTPUTREAL}/bad_timepoints.txt
		if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
			OUTDIR=${MAINDIR}/Logs/ica_july2011/fsl_motion_outlier_SUCCESS/GO_${GO}
		else
			OUTDIR=${MAINDIR}/Logs/ica_july2011/fsl_motion_outlier_FAIL/GO_${GO}
		fi
	fi





fi

mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
