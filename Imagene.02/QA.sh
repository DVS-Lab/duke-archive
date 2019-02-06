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


SUBJ=SUB_SUBNUM_SUB
TASK=SUB_TASK_SUB
GO=SUB_GO_SUB

DO_QA=1

#-----------RELEVANT EXCEPTIONS FOR FUNCTIONAL DATA-------- (not a complete list since only missing tasks are relevant for this script)

#20091208_10156 -- no resting state, only 1 of the 3 runs of the Risk Task
#20100119_10256 -- no resting state, only 1 of the 3 runs of the Risk Task
if [ $SUBJ -eq 10156 -o $SUBJ -eq 10256 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#20100120_10264 -- no resting state, missing 3rd run of the Risk Task
#20100120_10265 -- no resting state, missing 3rd run of the Risk Task
if [ $SUBJ -eq 10264 -o $SUBJ -eq 10265 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#20100126_10280 -- no resting state
#20100127_10287 -- no resting state
#20100128_10294 -- no resting state
#20100310_10481 -- no resting state
if [ $SUBJ -eq 10280 -o $SUBJ -eq 10287 -o $SUBJ -eq 10294 -o $SUBJ -eq 10481 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#20100224_10387 -- no resting state, also missing framing run3 and all of the Risk task -- subject had to get out of the scanner
if [ $SUBJ -eq 10387 ] && [ "$TASK" == "Risk" -o "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#20100309_10471 -- only has MID runs 1 and 2. missing everything else. scanner fail.
if [ $SUBJ -eq 10471 ] && [ "$TASK" == "Framing" -o "$TASK" == "Risk" -o "$TASK" == "Resting" ]; then
	DO_QA=0
fi


#20100330_10602: no resting state
if [ $SUBJ -eq 10602 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#20100413_10699: he didn't have any of McKell's task, but he still had resting state in run004_08
if [ $SUBJ -eq 10699 ] && [ "$TASK" == "Risk" ]; then
	DO_QA=0
fi

#20100818_11272/20100810_11235: no resting
if [ $SUBJ -eq 11272 -o $SUBJ -eq 11235 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#20100811_11244 -- only has MID runs 1. missing everything else. BIAC fail (server = full).
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Risk" ]; then
	DO_QA=0
fi
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Framing" ]; then
	DO_QA=0
fi
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#20100811_11245 -- missing MID1 and MID2, and resting. BIAC fail (server = full).
if [ $SUBJ -eq 11245 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi


#20110106_12082: no risk
if [ $SUBJ -eq 12082 ] && [ "$TASK" == "Risk" ]; then
	DO_QA=0
fi

#20110128_12193 -- nothing after MID2. just two runs of data. fail.
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Risk" ]; then
	DO_QA=0
fi
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Framing" ]; then
	DO_QA=0
fi


#20110311_12411 -- no resting
if [ $SUBJ -eq 12411 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#20110401_12580 -- only MID and resting state
if [ $SUBJ -eq 12580 ] && [ "$TASK" == "Framing" -o "$TASK" == "Risk" ]; then
	DO_QA=0
fi

#20110502_12815/20110512_12875: no resting
if [ $SUBJ -eq 12815 -o $SUBJ -eq 12875 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#12893/13011 : no resting
if [ $SUBJ -eq 12893 -o $SUBJ -eq 13011 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi


#11196: no resting (CHECK FAT SAT!)
if [ $SUBJ -eq 11196 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#11212: no resting or IRG2 (CHECK FAT SAT!)
if [ $SUBJ -eq 11212 ] && [ "$TASK" == "Resting" ]; then
	DO_QA=0
fi

#--------end exceptions list-------


MAINDIR=${EXPERIMENT}/Analysis/TaskData
TASKDIR=${MAINDIR}/${SUBJ}/${TASK}

QA_OUTPUT=${TASKDIR}/QA_${TASK}
if [ $GO -eq 1 ]; then
	rm -rf ${QA_OUTPUT}
fi
if [ -s $QA_OUTPUT/SFNR_run1.txt ]; then #test that the file is there and not empty
	echo "already exists and isn't empty: $QA_OUTPUT/SFNR_run1.txt"
	DO_QA=0
else
	rm -rf ${QA_OUTPUT}
fi

if [ $DO_QA -eq 1 ]; then
	cd $TASKDIR
	fmriqa_generate.pl --overwrite --timeselect 8: *.bxh ${QA_OUTPUT}
	if [ -d $QA_OUTPUT ]; then
		cd ${QA_OUTPUT}
		OUTDIR=${EXPERIMENT}/Analysis/TaskData/Logs/QA/success
	else
		OUTDIR=${EXPERIMENT}/Analysis/TaskData/Logs/QA/fail
		echo "FAIL: $QA_OUTPUT"
	fi
	grep 'mean SFNR (ROI in middle slice)' index.html | awk '{print $7}' > temp.txt
	#OUTPUT ASSUMING 3 RUNS: slice)</td><td>87.2</td><td>84.1</td><td>82.4</td></tr>
	sed -e 's@</td>@'"   "'@g' -e 's@<td>@'"   "'@g' <temp.txt> new_temp.txt
	#OUTPUT ASSUMING 3 RUNS: slice)      87.2      84.1      82.4   </tr>
	#awk '{print $1}' new_temp.txt # slice)
	awk '{print $2}' new_temp.txt > SFNR_run1.txt # 87.2
	if [ "$TASK" != "Resting" ]; then
		awk '{print $3}' new_temp.txt > SFNR_run2.txt # 84.1
		awk '{print $4}' new_temp.txt > SFNR_run3.txt # 82.4
	fi
	rm temp.txt new_temp.txt
else
	OUTDIR=${EXPERIMENT}/Analysis/TaskData/Logs/QA/skipped
fi


mkdir -p $OUTDIR

# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
