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
CON_NAME=SUB_NAME_VAR
GO=SUB_GO_VAR

#con_names = ["4star-1star_MINUS_gain-loss", "4star-1star_MINUS_5gain-5loss", "4star-1star_MINUS_5+2gain-5+2loss", "hot-not_MINUS_gain-loss", "hot-not_MINUS_5gain-5loss", "hot-not_MINUS_5+2gain-5+2loss"] 

if [ "$CON_NAME" == "4star-1star_MINUS_gain-loss" ]; then
	COPE1=6
	COPE2=8
elif [ "$CON_NAME" == "4star-1star_MINUS_5gain-5loss" ]; then
	COPE1=6
	COPE2=10
elif [ "$CON_NAME" == "4star-1star_MINUS_5+2gain-5+2loss" ]; then
	COPE1=6
	COPE2=12
elif [ "$CON_NAME" == "hot-not_MINUS_gain-loss" ]; then
	COPE1=8
	COPE2=8
elif [ "$CON_NAME" == "hot-not_MINUS_5gain-5loss" ]; then
	COPE1=8
	COPE2=10
elif [ "$CON_NAME" == "hot-not_MINUS_5+2gain-5+2loss" ]; then
	COPE1=8
	COPE2=12
fi

SMOOTH=6
#SocReward.01/Analysis/Cluster/PassiveTask/32918/32918_Model9_money_6mm_ST/32918_2ndlevel_money.gfeat
MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask
MAINDIR2=${MAINDIR}/${SUBJ}

MAINOUTPUT=${MAINDIR2}/L2_Paired_Tests
OUTPUT=${MAINOUTPUT}/${CON_NAME}
OUTPUTREAL=${OUTPUT}.gfeat


if [ $GO -eq 1 ]; then
	rm -rf $OUTPUTREAL
fi

if [ -d $OUTPUTREAL ]; then
	cd $OUTPUTREAL
	if [ -d cope1.feat ] && [ -d cope4.feat ]; then
		cd cope1.feat
		if [ -e cluster_mask_zstat1.nii.gz ]; then
			COPE1_GOOD=1
		else
			COPE1_GOOD=0
		fi
		cd cope4.feat
		if [ -e cluster_mask_zstat1.nii.gz ] && [ $COPE1_GOOD -eq 1 ]; then
			exit
		else
			cd $MAINDIR
			rm -rf $OUTPUTREAL
		fi
	else
		cd $MAINDIR
		rm -rf $OUTPUTREAL
	fi
fi

TEMPLATEDIR=${MAINDIR}/AnalysisTemplates/higherlevel_new
if [ $SUBJ -eq 33732 ]; then
	for N in `seq 10`; do
		NN=`printf '%02d' $N`
		if [ $N -lt 6 ]; then
			let RUN_NUM=$N+1
			COPE=$COPE1
			MODEL=Model9_faces_6mm_ST
		else
			let RUN_NUM=$N-4
			COPE=$COPE2
			MODEL=Model9_money_6mm_ST
		fi
		if [ $RUN_NUM -eq 4 ]; then
			continue
		fi
		eval INPUT${NN}=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run${RUN_NUM}.feat/stats/cope${COPE}.nii.gz
	done
	TEMPLATE=L2_2evs_8inputs.fsf
	cd $TEMPLATEDIR
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@INPUT01@'$INPUT01'@g' \
	-e 's@INPUT02@'$INPUT02'@g' \
	-e 's@INPUT04@'$INPUT04'@g' \
	-e 's@INPUT05@'$INPUT05'@g' \
	-e 's@INPUT06@'$INPUT06'@g' \
	-e 's@INPUT07@'$INPUT07'@g' \
	-e 's@INPUT09@'$INPUT09'@g' \
	-e 's@INPUT10@'$INPUT10'@g' \
	<$TEMPLATE> ${MAINDIR2}/2ndLvlFixed_${SUBJ}_${CON_NAME}.fsf
elif [ $SUBJ -eq 32976 ]; then
	MODEL=Model9_faces_6mm_ST
	INPUT01=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run3.feat/stats/cope${COPE1}.nii.gz
	INPUT02=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run4.feat/stats/cope${COPE1}.nii.gz
	INPUT04=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run5.feat/stats/cope${COPE1}.nii.gz
	INPUT05=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run6.feat/stats/cope${COPE1}.nii.gz
	MODEL=Model9_money_6mm_ST
	INPUT06=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run3.feat/stats/cope${COPE2}.nii.gz
	INPUT07=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run4.feat/stats/cope${COPE2}.nii.gz
	INPUT09=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run5.feat/stats/cope${COPE2}.nii.gz
	INPUT10=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run6.feat/stats/cope${COPE2}.nii.gz
	
	TEMPLATE=L2_2evs_8inputs.fsf
	cd $TEMPLATEDIR
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@INPUT01@'$INPUT01'@g' \
	-e 's@INPUT02@'$INPUT02'@g' \
	-e 's@INPUT04@'$INPUT04'@g' \
	-e 's@INPUT05@'$INPUT05'@g' \
	-e 's@INPUT06@'$INPUT06'@g' \
	-e 's@INPUT07@'$INPUT07'@g' \
	-e 's@INPUT09@'$INPUT09'@g' \
	-e 's@INPUT10@'$INPUT10'@g' \
	<$TEMPLATE> ${MAINDIR2}/2ndLvlFixed_${SUBJ}_${CON_NAME}.fsf
else
	for N in `seq 10`; do
		NN=`printf '%02d' $N`
		if [ $N -lt 6 ]; then
			let RUN_NUM=$N+1
			COPE=$COPE1
			MODEL=Model9_faces_6mm_ST
		else
			let RUN_NUM=$N-4
			COPE=$COPE2
			MODEL=Model9_money_6mm_ST
		fi
		eval INPUT${NN}=${MAINDIR2}/${SUBJ}_${MODEL}/${SUBJ}_run${RUN_NUM}.feat/stats/cope${COPE}.nii.gz
	done
	TEMPLATE=L2_2evs_10inputs.fsf
	cd $TEMPLATEDIR
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@INPUT01@'$INPUT01'@g' \
	-e 's@INPUT02@'$INPUT02'@g' \
	-e 's@INPUT03@'$INPUT03'@g' \
	-e 's@INPUT04@'$INPUT04'@g' \
	-e 's@INPUT05@'$INPUT05'@g' \
	-e 's@INPUT06@'$INPUT06'@g' \
	-e 's@INPUT07@'$INPUT07'@g' \
	-e 's@INPUT08@'$INPUT08'@g' \
	-e 's@INPUT09@'$INPUT09'@g' \
	-e 's@INPUT10@'$INPUT10'@g' \
	<$TEMPLATE> ${MAINDIR2}/2ndLvlFixed_${SUBJ}_${CON_NAME}.fsf
fi

NCOPES=4
cd ${MAINDIR2}
if [ -d $OUTPUTREAL ]; then
	echo "This one is already done. Exiting script..."
	exit
else
	feat ${MAINDIR2}/2ndLvlFixed_${SUBJ}_${CON_NAME}.fsf

	cd $OUTPUTREAL
	for j in `seq $NCOPES`; do
		COPE=cope${j}.feat
		cd $COPE
		rm -f filtered_func_data.nii.gz
		rm -f var_filtered_func_data.nii.gz
		rm -f stats/res4d.nii.gz
		cd ..
	done
fi

OUTDIR=$MAINDIR2

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 

mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
