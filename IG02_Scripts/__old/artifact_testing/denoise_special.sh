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


SUBJ=10782
#RUN=SUB_RUN_SUB
SMOOTH=6
#TASK=SUB_TASK_SUB
GO=1
#DENOISE=SUB_DENOISE_SUB


for TASK in "Framing" "MID" "Risk" "Resting"; do
	for DENOISE in "normal" "special"; do
		if [ $TASK == "Resting" ]; then
			RUNS=1
		else
			RUNS=3
		fi
		
		for RUN in `seq $RUNS`; do
			

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
			MAINOUTPUT=${SUBJDIR}/${TASK}/MELODIC/Smooth_${SMOOTH}mm
			
			
			if [ $SKIP -eq 1 ]; then
				echo "skipping exceptions: $SUBJ $TASK run $RUN"
				#OUTDIR=${MAINDIR}/Logs/ica/denoiser2/skips/GO_${GO}
			else
			
				RUNDIR=${MAINOUTPUT}/run${RUN}.ica
				if [ ${DENOISE} == "special" ]; then
					LABELS=${MAINOUTPUT}/bad_special/run${RUN}.txt
				else
					LABELS=${MAINOUTPUT}/bad/run${RUN}.txt
				fi
			
				BAD=`cat ${LABELS}`
				cd $RUNDIR
			
# 				if [ -e ${DENOISE}_denoised_data.nii.gz -a $GO -eq 1 ]; then
# 					rm -rf ${DENOISE}_denoised_data.nii.gz #delete older versions of denoised data if they're present
# 				fi

				if [ $GO -eq 1 ]; then
					rm -rf ${DENOISE}_denoised_data.nii.gz #delete older versions of denoised data if they're present
				fi

			
				#it is possible that some runs will not have any bad components, so this statement helps account for that
				if [ -n "$BAD" ]; then #making sure the run${RUN}.txt file isn't empty
					REGFILTCMD="fsl_regfilt -i filtered_func_data -o ${DENOISE}_denoised_data -d filtered_func_data.ica/melodic_mix -f $BAD"
					eval $REGFILTCMD #this will output your denoised data (denoised_data.nii.gz)
					echo $REGFILTCMD
					#OUTDIR=${MAINDIR}/Logs/ica/denoiser2/sucess/GO_${GO}
				else
					cp filtered_func_data.nii.gz ${DENOISE}_denoised_data.nii.gz
					echo "no bad components for ${SUBJ} ${RUN}. renaming input file to match others..."
					#OUTDIR=${MAINDIR}/Logs/ica/denoiser2/no_bad/GO_${GO}
				fi
			fi
		done
	done
done
OUTDIR=${MAINDIR}/Logs/ica/denoiser_all2/GO_${GO}
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
