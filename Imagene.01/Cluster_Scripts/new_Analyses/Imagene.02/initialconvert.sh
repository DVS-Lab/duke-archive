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


SUBJ_FULL=$1
SUBJ=$2

MAINFUNCDIR=${EXPERIMENT}/Data/Func
MAINANATDIR=${EXPERIMENT}/Data/Anat
NEWANATDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}
mkdir -p $NEWANATDIR

RUN_PREFIX=run004

if [ "$SUBJ_FULL" == "20091210_10169" ]; then
	echo "skipping anat..."
else
	cd $MAINANATDIR/${SUBJ_FULL}/series002 #the good anat is always **series002** because series200 has uneven intensities
	rm -rf ${SUBJ}_reoriented_anat.bxh
	rm -rf ${SUBJ}_reoriented_anat.dat
	bxhreorient --orientation LAS series002.bxh ${SUBJ}_reoriented_anat.bxh
	rm -rf $NEWANATDIR/${SUBJ}_anat.nii.gz
	bxh2analyze -s -b --niigz ${SUBJ}_reoriented_anat.bxh $NEWANATDIR/${SUBJ}_anat
	rm -rf ${SUBJ}_reoriented_anat.bxh
	rm -rf ${SUBJ}_reoriented_anat.dat
	cd $NEWANATDIR
	bet ${SUBJ}_anat ${SUBJ}_anat_brain -f 0.35 -R
fi


#-----------EXCEPTIONS FOR FUNCTIONAL DATA--------
#20091214_10179 (has anatomical data, but no functional data. what happened?)

#--changed time points starting on 10279. IRG cut to two runs. 
if [ $SUBJ -lt 10279 ]; then
	NRUNS=10
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=10
	REST=11
else
	NRUNS=9
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi

if [ $SUBJ -eq 10279 ]; then
	NRUNS=9
	MID=0; MID_STOP=2 #manually renamed folder and bxh files for run004_02 (changed to run004_00)
	FRAMING=3; FRAMING_STOP=5
	RISK=6; RISK_STOP=7
	REST=8
fi

#20091210_10168/20091210_10169 (restart; same subject; missing run3 of MID)
if [ "$SUBJ_FULL" == "20091210_10168" ]; then
	SUBJ=10168
	NRUNS=2
	MID=2; MID_STOP=3
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=10
	REST=11
fi
if [ "$SUBJ_FULL" == "20091210_10169" ]; then
	SUBJ=10168
	NRUNS=7
	MID=98; MID_STOP=99 #skip MID
	FRAMING=2; FRAMING_STOP=4
	RISK=5; RISK_STOP=7
	REST=8
	RUN_PREFIX=run003
fi

#20091208_10156 -- no resting state, only 1 of the 3 runs of the Risk Task
#20100119_10256 -- no resting state, only 1 of the 3 runs of the Risk Task
if [ $SUBJ -eq 10156 ] || [ $SUBJ -eq 10256 ]; then
	NRUNS=7
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=8
	REST=11
fi

#20100120_10264 -- no resting state, missing 3rd run of the Risk Task
#20100120_10265 -- no resting state, missing 3rd run of the Risk Task
if [ $SUBJ -eq 10264 ] || [ $SUBJ -eq 10265 ]; then
	NRUNS=8
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=11
fi

#20100126_10280 -- no resting state
#20100127_10287 -- no resting state
#20100128_10294 -- no resting state
#20100310_10481 -- no resting state
if [ $SUBJ -eq 10280 ] || [ $SUBJ -eq 10287 ] || [ $SUBJ -eq 10294 ] || [ $SUBJ -eq 10481 ]; then
	NRUNS=8
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi

#20100224_10387 -- no resting state, also missing framing run3 and all of the Risk task -- subject had to get out of the scanner
if [ $SUBJ -eq 10387 ]; then
	NRUNS=5
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=6
	RISK=8; RISK_STOP=9
	REST=10
fi



#20100212_10335 -- missing run3 of MID
#20100216_10350 -- missing run3 of MID
#20100216_10351 -- missing run3 of MID
if [ $SUBJ -eq 10335 ] || [ $SUBJ -eq 10350 ] || [ $SUBJ -eq 10351 ]; then
	NRUNS=8
	MID=2; MID_STOP=3
	FRAMING=4; FRAMING_STOP=6
	RISK=7; RISK_STOP=8
	REST=9
fi

#20100309_10471 -- only has MID runs 1 and 2. missing everything else. scanner fail.
if [ $SUBJ -eq 10471 ]; then
	NRUNS=2
	MID=2; MID_STOP=3
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
	RUN_PREFIX=run006
fi


R1=0; R2=0; R3=0; R4=0;
for RUNS in `seq $NRUNS`; do

	if [ $SUBJ -eq 10279 ]; then #maually renamed -- starts at run004_00
		let RUNS=$RUNS-1
		if [ $RUNS -eq 0 ]; then
			RUN_PREFIX=run004
		else
			RUN_PREFIX=run005
		fi
	else
		let RUNS=$RUNS+1	
	fi

	if [ $RUNS -lt 10 ]; then
		RUN=0${RUNS}
	else
		RUN=$RUNS
	fi

	

	if [ $RUNS -ge $MID ] && [ $RUNS -le $MID_STOP ]; then
		let R1=$R1+1
		MOUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/MID
		mkdir -p ${MOUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/${RUN_PREFIX}_${RUN}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
		if [ $SUBJ -lt 10387 ]; then #subjects prior to 10387 had the higher scaling factor
			pfile2bxh --elemtype=uint16 ${RUN_PREFIX}_${RUN}.pfh *.img ${RUN_PREFIX}_${RUN}.bxh
		else
			pfile2bxh ${RUN_PREFIX}_${RUN}.pfh *.img ${RUN_PREFIX}_${RUN}.bxh #only necessary for pre-March
		fi
		bxhreorient --orientation LAS ${RUN_PREFIX}_${RUN}.bxh reoriented_run${RUNS}.bxh

		extractsliceorder --fsl --overwrite reoriented_run${RUNS}.bxh ${MOUTDIR}/so_run${R1}.txt

		rm -rf ${MOUTDIR}/run${R1}.nii.gz
		rm -rf ${MOUTDIR}/run${R1}.bxh
		bxh2analyze -s --niigz reoriented_run${RUNS}.bxh ${MOUTDIR}/run${R1}
		BXHCMD="bxh2analyze -s --niigz reoriented_run${RUNS}.bxh ${MOUTDIR}/run${R1}"
		echo $BXHCMD
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
	fi


	if [ $RUNS -ge $FRAMING ] && [ $RUNS -le $FRAMING_STOP ];then
		let R2=$R2+1
		FOUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/Framing
		mkdir -p ${FOUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/${RUN_PREFIX}_${RUN}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
		if [ $SUBJ -lt 10387 ]; then #subjects prior to 10387 had the higher scaling factor
			pfile2bxh --elemtype=uint16 ${RUN_PREFIX}_${RUN}.pfh *.img ${RUN_PREFIX}_${RUN}.bxh
		else
			pfile2bxh ${RUN_PREFIX}_${RUN}.pfh *.img ${RUN_PREFIX}_${RUN}.bxh #only necessary for pre-March
		fi
		bxhreorient --orientation LAS ${RUN_PREFIX}_${RUN}.bxh reoriented_run${RUNS}.bxh

		extractsliceorder --fsl --overwrite reoriented_run${RUNS}.bxh ${FOUTDIR}/so_run${R2}.txt

		rm -rf ${FOUTDIR}/run${R2}.nii.gz
		rm -rf ${FOUTDIR}/run${R2}.bxh
		bxh2analyze -s --niigz reoriented_run${RUNS}.bxh ${FOUTDIR}/run${R2}
		BXHCMD="bxh2analyze -s --niigz reoriented_run${RUNS}.bxh ${FOUTDIR}/run${R2}"
		echo $BXHCMD
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
	fi


	if [ $RUNS -ge $RISK ] && [ $RUNS -le $RISK_STOP ];then
		let R3=$R3+1
		ROUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/Risk
		mkdir -p ${ROUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/${RUN_PREFIX}_${RUN}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
		if [ $SUBJ -lt 10387 ]; then #subjects prior to 10387 had the higher scaling factor
			pfile2bxh --elemtype=uint16 ${RUN_PREFIX}_${RUN}.pfh *.img ${RUN_PREFIX}_${RUN}.bxh
		else
			pfile2bxh ${RUN_PREFIX}_${RUN}.pfh *.img ${RUN_PREFIX}_${RUN}.bxh #only necessary for pre-March
		fi
		bxhreorient --orientation LAS ${RUN_PREFIX}_${RUN}.bxh reoriented_run${RUNS}.bxh

		extractsliceorder --fsl --overwrite reoriented_run${RUNS}.bxh ${ROUTDIR}/so_run${R3}.txt

		rm -rf ${ROUTDIR}/run${R3}.nii.gz
		rm -rf ${ROUTDIR}/run${R3}.bxh
		bxh2analyze -s --niigz reoriented_run${RUNS}.bxh ${ROUTDIR}/run${R3}
		BXHCMD="bxh2analyze -s --niigz reoriented_run${RUNS}.bxh ${ROUTDIR}/run${R3}"
		echo $BXHCMD
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
	fi


	if [ $RUNS -eq $REST ];then
		let R4=$R4+1
		RESTOUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/Resting
		mkdir -p ${RESTOUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/${RUN_PREFIX}_${RUN}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
		if [ $SUBJ -lt 10387 ]; then #subjects prior to 10387 had the higher scaling factor
			pfile2bxh --elemtype=uint16 ${RUN_PREFIX}_${RUN}.pfh *.img ${RUN_PREFIX}_${RUN}.bxh
		else
			pfile2bxh ${RUN_PREFIX}_${RUN}.pfh *.img ${RUN_PREFIX}_${RUN}.bxh #only necessary for pre-March
		fi
		bxhreorient --orientation LAS ${RUN_PREFIX}_${RUN}.bxh reoriented_run${RUNS}.bxh
		
		extractsliceorder --fsl --overwrite reoriented_run${RUNS}.bxh ${RESTOUTDIR}/so_run${R4}.txt

		rm -rf ${RESTOUTDIR}/run${R4}.nii.gz
		rm -rf ${RESTOUTDIR}/run${R4}.bxh
		bxh2analyze -s --niigz reoriented_run${RUNS}.bxh ${RESTOUTDIR}/run${R4}
		BXHCMD="bxh2analyze -s --niigz reoriented_run${RUNS}.bxh ${RESTOUTDIR}/run${R4}"
		echo $BXHCMD
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
	fi

done


OUTDIR=${EXPERIMENT}/Analysis/TaskData/Logs/initialconvert
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
