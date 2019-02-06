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

COPE=$1 #2 for linear, 3 for quad
USE_VBM=$2
DEMEAN=$3
EXHAUSTIVE=$4

if [ $COPE -eq 2 ]; then
	OUTPUTNAME=linear
elif [ $COPE -eq 3 ]; then
	OUTPUTNAME=quad
else
	exit
fi

#/SocReward.03/Analysis/FSL/Active/NEWEST/NEWQuadratic/WObad/VBM/WOExchanges/Linear_WCEVs/Smooth_6mm/cope2.gfeat/cope1.feat
#randomise -i <4D_input_data> -o <output_rootname> -d design.mat -t design.con -m <mask_image> -n 500 -D -T 

# If you have fewer than 20 subjects (approx. 20 DF), then you will usually see an increase in power by using variance smoothing, as in
# randomise -i OneSamp4D -o OneSampT -1 -v 5 -T
# which does a 5mm HWHM variance smoothing. 

MAINDIR=${EXPERIMENT}/Analysis/FSL
VBMFILE=${MAINDIR}/VBM_new5.nii.gz
DATADIR=${MAINDIR}/Active/NEWEST/NEWQuadratic/WObad/WOExchanges/Linear_WCEVs/Smooth_6mm/cope${COPE}.gfeat/cope1.feat

INPUTDATA=${DATADIR}/filtered_func_data.nii.gz
MAT=${DATADIR}/design.mat
CON=${DATADIR}/design.con
MASK=${DATADIR}/mask.nii.gz

if [ $EXHAUSTIVE -eq 1 ]; then
	MAINOUTPUT=${MAINDIR}/Active/NEWEST/NEWQuadratic/randomise_v5_EXHAUSTIVEperms
	mkdir -p ${MAINOUTPUT}
	if [ $DEMEAN -eq 1 -a $USE_VBM -eq 1 ]; then
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME}_vbm_demeaned_ -d ${MAT} -t ${CON} -m ${MASK} -n 0 -D -v 5 --vxf ${VBMFILE} -T
	elif [ $DEMEAN -eq 1 -a $USE_VBM -eq 0 ]; then
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME}_demeaned_ -d ${MAT} -t ${CON} -m ${MASK} -n 0 -D -v 5 -T
	elif [ $DEMEAN -eq 0 -a $USE_VBM -eq 1 ]; then
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME}_vbm_ -d ${MAT} -t ${CON} -m ${MASK} -n 0 -v 5 --vxf ${VBMFILE} -T
	elif [ $DEMEAN -eq 0 -a $USE_VBM -eq 0 ]; then
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME}_ -d ${MAT} -t ${CON} -m ${MASK} -n 0 -v 5 -T
	else
		echo "no valid options..."
	fi
else
	MAINOUTPUT=${MAINDIR}/Active/NEWEST/NEWQuadratic/randomise_v5_10000perms
	mkdir -p ${MAINOUTPUT}
	if [ $DEMEAN -eq 1 -a $USE_VBM -eq 1 ]; then
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME}_vbm_demeaned_ -d ${MAT} -t ${CON} -m ${MASK} -n 10000 -D -v 5 --vxf ${VBMFILE} -T
	elif [ $DEMEAN -eq 1 -a $USE_VBM -eq 0 ]; then
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME}_demeaned_ -d ${MAT} -t ${CON} -m ${MASK} -n 10000 -D -v 5 -T
	elif [ $DEMEAN -eq 0 -a $USE_VBM -eq 1 ]; then
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME}_vbm_ -d ${MAT} -t ${CON} -m ${MASK} -n 10000 -v 5 --vxf ${VBMFILE} -T
	elif [ $DEMEAN -eq 0 -a $USE_VBM -eq 0 ]; then
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME}_ -d ${MAT} -t ${CON} -m ${MASK} -n 10000 -v 5 -T
		randomise -i ${INPUTDATA} -o ${MAINOUTPUT}/${OUTPUTNAME} -d ${MAT} -t ${CON} -m ${MASK} -n 10000 -v 5 -x
	else
		echo "no valid options..."
	fi
fi

OUTDIR=$MAINOUTPUT/logs
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
