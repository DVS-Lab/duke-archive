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


SUBJ=SUB_SUBNUM_VAR
SMOOTH=SUB_SMOOTH_VAR
GO=SUB_GO_VAR
PERM=SUB_OPTION_VAR
AR1=SUB_AR1_VAR


FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh

MAINDIR=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance
SUBJECT_MAIN=${MAINDIR}/${SUBJ}/TEST/NEW_ANALYSES2
# S:\Analysis\Cluster\forAlon_NeuralFinance\32918\NEW_ANALYSES2\32918_FEAT_native_6mm_PERM1
#SUBJDIR=${SUBJECT_MAIN}/NEW_ANALYSES/${SUBJ}_FEAT_${SPACE}_${SMOOTH}mm_PERM${PERM}

if [ $AR1 -eq 1 ]; then
	SUBJDIR=${SUBJECT_MAIN}/${SUBJ}_FEAT_native_${SMOOTH}mm_PERM${PERM}
else
	SUBJDIR=${SUBJECT_MAIN}/${SUBJ}_FEAT_native_${SMOOTH}mm_PERM${PERM}_noAR1
fi

MAINOUTPUT=${SUBJDIR}
mkdir -p ${MAINOUTPUT}

OUTPUT=${MAINOUTPUT}/${SUBJ}_level2
OUTPUTREAL=${OUTPUT}.gfeat

if [ $GO -eq 1 ]; then
	rm -rf $OUTPUTREAL
fi

if [ -d $OUTPUTREAL ]; then
	cd $OUTPUTREAL
	if [ -d cope1.feat ] && [ -d cope2.feat ]; then
		cd cope1.feat
		if [ -e cluster_mask_zstat1.nii.gz ]; then
			COPE1_GOOD=1
		else
			COPE1_GOOD=0
		fi
		cd cope2.feat
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

MAINDIR2=$SUBJDIR

TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance/AnalysisTemplates/NEW_FSL_4p1
cd ${TEMPLATEDIR}
STANDARD=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance/ROIs_NEW/standard_4mm.nii.gz


if [ $SUBJ -eq 33732 ]; then
	INPUT01=${MAINDIR2}/run2.feat
	INPUT02=${MAINDIR2}/run3.feat
	INPUT03=${MAINDIR2}/run5.feat
	INPUT04=${MAINDIR2}/run6.feat
	
	TEMPLATE=level2_4r_2COPE.fsf
	cd $TEMPLATEDIR
	for i in $TEMPLATE; do
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	    -e 's@INPUT01@'$INPUT01'@g' \
	    -e 's@INPUT02@'$INPUT02'@g' \
	    -e 's@INPUT03@'$INPUT03'@g' \
	    -e 's@INPUT04@'$INPUT04'@g' <$i> ${MAINDIR2}/2ndLvlFixed_${SUBJ}.fsf
	done

else
	INPUT01=${MAINDIR2}/run2.feat
	INPUT02=${MAINDIR2}/run3.feat
	INPUT03=${MAINDIR2}/run4.feat
	INPUT04=${MAINDIR2}/run5.feat
	INPUT05=${MAINDIR2}/run6.feat
	
	TEMPLATE=level2_5r_2COPE_junk.fsf
	cd $TEMPLATEDIR
	for i in $TEMPLATE; do
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	    -e 's@INPUT01@'$INPUT01'@g' \
	    -e 's@INPUT02@'$INPUT02'@g' \
	    -e 's@INPUT03@'$INPUT03'@g' \
	    -e 's@STANDARD@'$STANDARD'@g' \
	    -e 's@INPUT04@'$INPUT04'@g' \
	    -e 's@INPUT05@'$INPUT05'@g' <$i> ${MAINDIR2}/2ndLvlFixed_${SUBJ}.fsf
	done
fi

NCOPES=9
if [ -d $OUTPUTREAL ]; then
	echo "This one is already done. Exiting script..."
	exit
else
	feat ${MAINDIR2}/2ndLvlFixed_${SUBJ}.fsf

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


OUTDIR=${MAINOUTPUT}/Logs
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
