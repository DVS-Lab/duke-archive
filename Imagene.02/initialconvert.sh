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

#these set the start numbers for each task
R1=0 #MID
R2=0 #Framing
R3=0 #Risk
R4=0 #Resting



RUN_PREFIX=run004
#20100921_11430/11431
if [ "$SUBJ_FULL" == "20091210_10169" -o "$SUBJ_FULL" == "20100921_11431" ]; then
	echo "skipping anat..."
elif [ "$SUBJ_FULL" == "20100623_11067" -o  "$SUBJ_FULL" == "20100907_11364" -o "$SUBJ_FULL" == "20100818_11274" ]; then
#20100623_11067 & 20100907_11364 have all their data, but moved during anatomical. re-did anat (series004; series006)
	cd $MAINANATDIR/${SUBJ_FULL}/series004 #the good anat is always **series002** because series200 has uneven intensities
	rm -rf ${SUBJ}_reoriented_anat.bxh
	rm -rf ${SUBJ}_reoriented_anat.dat
	bxhreorient --orientation LAS series004.bxh ${SUBJ}_reoriented_anat.bxh
	rm -rf $NEWANATDIR/${SUBJ}_anat.nii.gz
	bxh2analyze -s -b --niigz ${SUBJ}_reoriented_anat.bxh $NEWANATDIR/${SUBJ}_anat
	rm -rf ${SUBJ}_reoriented_anat.bxh
	rm -rf ${SUBJ}_reoriented_anat.dat
	cd $NEWANATDIR
	bet ${SUBJ}_anat ${SUBJ}_anat_brain -f 0.35 -R
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


#20100330_10602: no resting state
if [ $SUBJ -eq 10602 ]; then
	NRUNS=9
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi

#20100413_10699: he didn't have any of McKell's task, but he still had resting state in run004_08
if [ $SUBJ -eq 10699 ]; then
	NRUNS=7
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=9; RISK_STOP=10 #skip
	REST=8
fi

#----new exceptions: june, july, august, september
#20100623_11067 & 20100907_11364 & 20100818_11274 have all their data, but moved during anatomical. re-did anat (series004; funcs in series006)
if [ "$SUBJ_FULL" == "20100623_11067" -o  "$SUBJ_FULL" == "20100907_11364" -o "$SUBJ_FULL" == "20100818_11274" ]; then
	RUN_PREFIX=run006
fi

#20100615_11024: no clue what happened, but all data is under series005
if [ "$SUBJ_FULL" == "20100615_11024" ]; then
	RUN_PREFIX=run005
fi


#20100818_11272/20100810_11235: no resting
if [ $SUBJ -eq 11272 -o $SUBJ -eq 11235 ]; then
	NRUNS=9
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi


#20100921_11430/11431 (restart; same subject; no missing data, putting everything under first anat)
if [ "$SUBJ_FULL" == "20100921_11430" ]; then
	SUBJ=11430
	NRUNS=3
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi
if [ "$SUBJ_FULL" == "20100921_11431" ]; then
	SUBJ=11430
	NRUNS=6
	MID=98; MID_STOP=99 #skip MID
	FRAMING=2; FRAMING_STOP=4
	RISK=5; RISK_STOP=6
	REST=7
fi

#20100811_11244 -- only has MID runs 1. missing everything else. BIAC fail (server = full).
if [ $SUBJ -eq 11244 ]; then
	NRUNS=1
	MID=2; MID_STOP=3
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi

#20100811_11245 -- missing MID1 and MID2, and resting. BIAC fail (server = full).
if [ $SUBJ -eq 11245 ]; then
	R1=2
	NRUNS=8
	MID=4; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10 #no resting
fi

#20110106_12082: no risk
if [ $SUBJ -eq 12082 ]; then
	NRUNS=7
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=80; RISK_STOP=90
	REST=8
fi

#20110128_12193 -- nothing after MID2. just two runs of data. fail.
if [ $SUBJ -eq 12193 ]; then
	NRUNS=2
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi

#----new
#20110307_12372 -- runs out of order. got the last run of GC3 after IG2 and before resting
if [ $SUBJ -eq 12372 ]; then
	NRUNS=9
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=6
	RISK=7; RISK_STOP=9
	REST=10
	POSTHOCSWAP=1 #rIRG3 will be moved into GC3 at the end of this script
fi

#20110311_12411 -- no resting
if [ $SUBJ -eq 12411 ]; then
	NRUNS=8
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi

#20110401_12580 -- only MID and resting state
if [ $SUBJ -eq 12580 ]; then
	NRUNS=4
	MID=2; MID_STOP=4
	FRAMING=50; FRAMING_STOP=70
	RISK=80; RISK_STOP=90
	REST=5
fi

#20110502_12815/20110512_12875: no resting
if [ $SUBJ -eq 12815 -o $SUBJ -eq 12875 ]; then
	NRUNS=8
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi

#20110512_12879 -- restart after Framing
if [ $SUBJ -eq 12879 ]; then
	NRUNS=9
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=80; RISK_STOP=90 #switch to series007. just doing these separately
	REST=100
fi

#12893/13011 : no resting
if [ $SUBJ -eq 12893 -o $SUBJ -eq 13011 ]; then
	NRUNS=8
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi


#11196: no resting, no GC3, no IRG2 (CHECK FAT SAT!)
if [ $SUBJ -eq 11196 ]; then
	NRUNS=6
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=6
	RISK=7; RISK_STOP=9
	REST=10
fi

#11210: no MID3, no GC3 (CHECK FAT SAT!)
if [ $SUBJ -eq 11210 ]; then
	NRUNS=7
	MID=2; MID_STOP=3
	FRAMING=4; FRAMING_STOP=5
	RISK=6; RISK_STOP=7
	REST=8
fi

#11212: no resting or IRG2 (CHECK FAT SAT!)
if [ $SUBJ -eq 11212 ]; then
	NRUNS=7
	MID=2; MID_STOP=4
	FRAMING=5; FRAMING_STOP=7
	RISK=8; RISK_STOP=9
	REST=10
fi

#--------------end most exceptions-------------------


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
		#RUN=0${RUN}
	fi



	if [ $RUNS -ge $MID ] && [ $RUNS -le $MID_STOP ]; then
		let R1=$R1+1
		MOUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/MID
		mkdir -p ${MOUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/${RUN_PREFIX}_${RUN}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat

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

#only relevant for:
#20110307_12372 -- runs out of order. got the last run of GC3 after IG2 and before resting
if [ $POSTHOCSWAP -eq 1 ]; then
	mv ${ROUTDIR}/run3* ${FOUTDIR}/.
	mv ${ROUTDIR}/so_run3.txt ${FOUTDIR}/.
fi

if [ $SUBJ -eq 12879 ]; then
	RUN_PREFIX=run007
	NRUNS=3
	RISK=2; RISK_STOP=3 #switch to series007. just doing these separately
	REST=4

	for RUNS in `seq $NRUNS`; do
		let RUNS=$RUNS+1	
		RUN=0${RUNS}
		if [ $RUNS -ge $RISK ] && [ $RUNS -le $RISK_STOP ];then
			let R3=$R3+1
				
			ROUTDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/Risk
			mkdir -p ${ROUTDIR}
			cd ${MAINFUNCDIR}/${SUBJ_FULL}/${RUN_PREFIX}_${RUN}
			rm -rf reoriented_run${RUNS}.bxh
			rm -rf reoriented_run${RUNS}.dat
	
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
fi
OUTDIR=${EXPERIMENT}/Analysis/TaskData/Logs/initialconvert/may2011
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
