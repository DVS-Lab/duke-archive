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
 
# Need to input global EXPERIMENT, and inputs BXHINFILE, OUTDIR and OUTPRE
# BXHINFILE is the input file to convert
# OUTDIR is where the output folder will go
# OUTPRE is the output prefix of the data
# Example:
# qsub -v EXPERIMENT=Dummy.01 qsub_bxh2analyze \
# EXPERIMENT/Data/Func/99999/run01/run001.bxh EXPERIMENT/Data/Func/99999/fsl4D run01
 
 
#"20070328_32904 32904 11" 
 
#for LIST in "20070403_32918 32918 11"; do

#set -- $LIST


# MID is runs 1-3 -- 212 time points
# Framing is runs 4-6 -- 180 time points
# Gambling is runs 7-9 -- 134 time points
# Resting is run 10 -- 180 time points

# Exceptions: 47731 (time points), 47878, 47945, 48152

SUBJ_FULL=$1
SUBJ=$2
JUST_ANAT=$3

MAINFUNCDIR=${EXPERIMENT}/Data/Func
MAINANATDIR=${EXPERIMENT}/Data/Anat
NEWANATDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}
mkdir -p $NEWANATDIR

if [ $SUBJ -eq 48097 ] || [ $SUBJ -eq 48309 ]; then
	cd $MAINANATDIR/${SUBJ_FULL}/series003
	DCM=`ls -1 *.dcm | wc -l`
	if [ ! $DCM -eq 68 ]; then
		for F in `seq -w 100`; do
			echo "FAIL!!!! $F"
		done
	fi
else
	cd $MAINANATDIR/${SUBJ_FULL}/series002
	DCM=`ls -1 *.dcm | wc -l`
	if [ ! $DCM -eq 68 ]; then
		for F in `seq -w 100`; do
			echo "FAIL!!!! $F"
		done
	fi
fi

if [ $SUBJ -eq 48349 ]; then
	cd $MAINANATDIR/20090409_48348/series002
	DCM=`ls -1 *.dcm | wc -l`
	if [ ! $DCM -eq 68 ]; then
		for F in `seq -w 100`; do
			echo "FAIL!!!! $F"
		done
	fi
fi

if [ $SUBJ -eq 48335 ]; then
	cd $MAINANATDIR/20090408_48334/series002
	DCM=`ls -1 *.dcm | wc -l`
	if [ ! $DCM -eq 68 ]; then
		for F in `seq -w 100`; do
			echo "FAIL!!!! $F"
		done
	fi
fi

#cd $MAINANATDIR/20090408_48334/series002
rm -rf ${SUBJ}_reoriented_anat.bxh
rm -rf ${SUBJ}_reoriented_anat.dat
bxhreorient --orientation LAS series*.bxh ${SUBJ}_reoriented_anat.bxh
rm -rf $NEWANATDIR/${SUBJ}_anat.nii.gz
bxh2analyze -s -b --niigz ${SUBJ}_reoriented_anat.bxh $NEWANATDIR/${SUBJ}_anat
rm -rf ${SUBJ}_reoriented_anat.bxh
rm -rf ${SUBJ}_reoriented_anat.dat
cd $NEWANATDIR
bet ${SUBJ}_anat ${SUBJ}_anat_brain -f 0.35 -R



RUNS=10
MID=1; MID_STOP=3
FRAMING=4; FRAMING_STOP=6
GAMBLING=7; GAMBLING_STOP=9
REST=10


if [ $SUBJ -eq 47878 ]; then
	RUNS=10
	MID=1; MID_STOP=3
	FRAMING=7; FRAMING_STOP=9
	GAMBLING=4; GAMBLING_STOP=6
	REST=10
fi

if [ $SUBJ -eq 48152 ]; then
	RUNS=9
	MID=4; MID_STOP=6
	FRAMING=1; FRAMING_STOP=3
	GAMBLING=7; GAMBLING_STOP=9
fi

if [ $SUBJ -eq 47945 ]; then
	RUNS=9
	MID=1; MID_STOP=2
	FRAMING=3; FRAMING_STOP=5
	GAMBLING=6; GAMBLING_STOP=8
	REST=9
fi

if [ $SUBJ -eq 48271 ]; then
	RUNS=9
	MID=1; MID_STOP=3
	FRAMING=4; FRAMING_STOP=6
	GAMBLING=7; GAMBLING_STOP=9
fi
 

if [ $JUST_ANAT -eq 1 ]; then
	echo "done with anats... and skipping funcs"
else
	R1=0; R2=0; R3=0; R4=0;
	for RUNS in `seq $RUNS`; do
	
		if [ $RUNS -ge $MID ] && [ $RUNS -le $MID_STOP ];then
			let R1=$R1+1
			MOUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/MID
			mkdir -p ${MOUTDIR}
			cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUNS}
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
			bxhreorient --orientation LAS run*${RUNS}.bxh reoriented_run${RUNS}.bxh
			rm -rf ${MOUTDIR}/run${R1}.nii.gz
			bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${MOUTDIR}/run${R1}
			BXHCMD="bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${MOUTDIR}/run${R1}"
			echo $BXHCMD
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
		fi
	
	
		if [ $RUNS -ge $FRAMING ] && [ $RUNS -le $FRAMING_STOP ];then
			let R2=$R2+1
			FOUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/Framing
			mkdir -p ${FOUTDIR}
			cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUNS}
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
			bxhreorient --orientation LAS run*${RUNS}.bxh reoriented_run${RUNS}.bxh
			rm ${FOUTDIR}/run${R2}.nii.gz
			bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${FOUTDIR}/run${R2}
			BXHCMD="bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${FOUTDIR}/run${R2}"
			echo $BXHCMD
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
		fi
	
	
		if [ $RUNS -ge $GAMBLING ] && [ $RUNS -le $GAMBLING_STOP ];then
			let R3=$R3+1
			GOUTPUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/Gambling
			mkdir -p ${GOUTPUTDIR}
			cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUNS}
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
			bxhreorient --orientation LAS run*${RUNS}.bxh reoriented_run${RUNS}.bxh
			rm -rf ${GOUTPUTDIR}/run${R3}.nii.gz
			bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${GOUTPUTDIR}/run${R3}
			BXHCMD="bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${GOUTPUTDIR}/run${R3}"
			echo $BXHCMD
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
		fi
	
	
		if [ $RUNS -eq $REST ];then
			let R4=$R4+1
			ROUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/Resting
			mkdir -p ${ROUTDIR}
			cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUNS}
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
			bxhreorient --orientation LAS run*${RUNS}.bxh reoriented_run${RUNS}.bxh
			rm -rf ${ROUTDIR}/run${R4}.nii.gz
			bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${ROUTDIR}/run${R4}
			BXHCMD="bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${ROUTDIR}/run${R4}"
			echo $BXHCMD
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
		fi
	
	done
fi


OUTDIR=${EXPERIMENT}/Analysis/TaskData/Job_logs_NEW_re-do_anats_only3
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
