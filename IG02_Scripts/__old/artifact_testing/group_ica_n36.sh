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

SMOOTH=6
GO=1
N=0

#not sure why 10303 was in this list...
for SUBJ in 10156 10168 10181 10199 10255 10256 10264 10265 10279 10280 10281 10286 10287 10294 10304 10305 10306 10314 10315 10335 10350 10351 10352 10358 10359 10360 10387 10414 10415 10416 10424 10425 10426 10471 10472 10474 10481 10482 10483 10512 10515 10521 10523 10524 10525; do

##removed: "10169" because all data is in 10168
#subnums = [ "10264", "10265" ]

# for TASK in "Framing" "MID" "Risk" "Resting"; do
for TASK in "Resting"; do

if [ "$TASK" == "Resting" ]; then
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

MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/${TASK}/MELODIC/Smooth_${SMOOTH}mm #change

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.ica


ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
DATA=${OUTPUTREAL}/normal_denoised_data.nii.gz #change

if [ $SKIP -eq 1 ]; then
	continue
else
	let N=$N+1
	FUNCFILENAME=${DATA}
	ANATFILENAME=${ANAT}
	NN=`printf '%03d' $N` #this pads the numbers with zero
	eval ANAT${NN}=${ANATFILENAME}
	eval DATA${NN}=${FUNCFILENAME}
fi

done
done
done

OUTPUT=${MAINDIR}/resting_all_temp_cat_n36_normal_denoised #change
if [ -d $OUTPUT.gica ]; then
	rm -rf $OUTPUT.gica
fi


TEMPLATEDIR=${EXPERIMENT}/Analysis/TaskData/Templates
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA001@'$DATA001'@g' \
-e 's@DATA002@'$DATA002'@g' \
-e 's@DATA003@'$DATA003'@g' \
-e 's@DATA004@'$DATA004'@g' \
-e 's@DATA005@'$DATA005'@g' \
-e 's@DATA006@'$DATA006'@g' \
-e 's@DATA007@'$DATA007'@g' \
-e 's@DATA008@'$DATA008'@g' \
-e 's@DATA009@'$DATA009'@g' \
-e 's@DATA010@'$DATA010'@g' \
-e 's@DATA011@'$DATA011'@g' \
-e 's@DATA012@'$DATA012'@g' \
-e 's@DATA013@'$DATA013'@g' \
-e 's@DATA014@'$DATA014'@g' \
-e 's@DATA015@'$DATA015'@g' \
-e 's@DATA016@'$DATA016'@g' \
-e 's@DATA017@'$DATA017'@g' \
-e 's@DATA018@'$DATA018'@g' \
-e 's@DATA019@'$DATA019'@g' \
-e 's@DATA020@'$DATA020'@g' \
-e 's@DATA021@'$DATA021'@g' \
-e 's@DATA022@'$DATA022'@g' \
-e 's@DATA023@'$DATA023'@g' \
-e 's@DATA024@'$DATA024'@g' \
-e 's@DATA025@'$DATA025'@g' \
-e 's@DATA026@'$DATA026'@g' \
-e 's@DATA027@'$DATA027'@g' \
-e 's@DATA028@'$DATA028'@g' \
-e 's@DATA029@'$DATA029'@g' \
-e 's@DATA030@'$DATA030'@g' \
-e 's@DATA031@'$DATA031'@g' \
-e 's@DATA032@'$DATA032'@g' \
-e 's@DATA033@'$DATA033'@g' \
-e 's@DATA034@'$DATA034'@g' \
-e 's@DATA035@'$DATA035'@g' \
-e 's@DATA036@'$DATA036'@g' \
-e 's@ANAT001@'$ANAT001'@g' \
-e 's@ANAT002@'$ANAT002'@g' \
-e 's@ANAT003@'$ANAT003'@g' \
-e 's@ANAT004@'$ANAT004'@g' \
-e 's@ANAT005@'$ANAT005'@g' \
-e 's@ANAT006@'$ANAT006'@g' \
-e 's@ANAT007@'$ANAT007'@g' \
-e 's@ANAT008@'$ANAT008'@g' \
-e 's@ANAT009@'$ANAT009'@g' \
-e 's@ANAT010@'$ANAT010'@g' \
-e 's@ANAT011@'$ANAT011'@g' \
-e 's@ANAT012@'$ANAT012'@g' \
-e 's@ANAT013@'$ANAT013'@g' \
-e 's@ANAT014@'$ANAT014'@g' \
-e 's@ANAT015@'$ANAT015'@g' \
-e 's@ANAT016@'$ANAT016'@g' \
-e 's@ANAT017@'$ANAT017'@g' \
-e 's@ANAT018@'$ANAT018'@g' \
-e 's@ANAT019@'$ANAT019'@g' \
-e 's@ANAT020@'$ANAT020'@g' \
-e 's@ANAT021@'$ANAT021'@g' \
-e 's@ANAT022@'$ANAT022'@g' \
-e 's@ANAT023@'$ANAT023'@g' \
-e 's@ANAT024@'$ANAT024'@g' \
-e 's@ANAT025@'$ANAT025'@g' \
-e 's@ANAT026@'$ANAT026'@g' \
-e 's@ANAT027@'$ANAT027'@g' \
-e 's@ANAT028@'$ANAT028'@g' \
-e 's@ANAT029@'$ANAT029'@g' \
-e 's@ANAT030@'$ANAT030'@g' \
-e 's@ANAT031@'$ANAT031'@g' \
-e 's@ANAT032@'$ANAT032'@g' \
-e 's@ANAT033@'$ANAT033'@g' \
-e 's@ANAT034@'$ANAT034'@g' \
-e 's@ANAT035@'$ANAT035'@g' \
-e 's@ANAT036@'$ANAT036'@g' \
<group_melodic_n36.fsf> ${MAINOUTPUT}/group_n36.fsf

feat ${MAINOUTPUT}/group_n36.fsf





# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
