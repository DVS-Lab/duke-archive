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
# #$ -M david.v.smith@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02
sleep 5s


ROI=SUB_ROI_SUB
DATATYPE=SUB_DATATYPE_SUB


MAINDIR=${EXPERIMENT}/Analysis/HighRes_GT/forCNS_LesionMVPA/PyMVPA_DVS
OUTPUTDIR=${MAINDIR}/thresh_weights01
mkdir -p $OUTPUTDIR

SENSDIR=${MAINDIR}/Analysis_equal/ROIs_weight_selected/LinearNuSVMC/sens_maps/new/2/${DATATYPE}/neglect
cd $SENSDIR
fslmerge -t roi_${ROI}_${DATATYPE} neglect_sensmap_down_LinearNuSVMC_new_${ROI}_${DATATYPE}data_perm0????_mean.nii.gz
NVOLS=`fslnvols roi_${ROI}_${DATATYPE}`
if [ ! $NVOLS -eq 1001 ]; then
	echo -e "missing files for $ROI $DATATYPE $NVOLS" >> $MAINDIR/missing_files01.txt
fi
fslmaths roi_${ROI}_${DATATYPE} roi_${ROI}_${DATATYPE} -odt float
fslmaths roi_${ROI}_${DATATYPE} -Tperc 99.5 roi_${ROI}_${DATATYPE}_perm_upper
fslmaths roi_${ROI}_${DATATYPE} -Tperc 0.5 roi_${ROI}_${DATATYPE}_perm_lower
fslroi roi_${ROI}_${DATATYPE} roi_${ROI}_${DATATYPE}_real 0 1
fslroi roi_${ROI}_${DATATYPE} roi_${ROI}_${DATATYPE}_perm 1 1000
fslmaths roi_${ROI}_${DATATYPE}_real -sub roi_${ROI}_${DATATYPE}_perm_upper -thr 0 roi_${ROI}_${DATATYPE}_real_above_upper
fslmaths roi_${ROI}_${DATATYPE}_real -sub roi_${ROI}_${DATATYPE}_perm_lower  -uthr 0 roi_${ROI}_${DATATYPE}_real_below_lower
fslmaths roi_${ROI}_${DATATYPE}_real_below_lower -abs -add roi_${ROI}_${DATATYPE}_real_above_upper -bin roi_${ROI}_${DATATYPE}_mask -odt char
fslmaths roi_${ROI}_${DATATYPE}_real -mas roi_${ROI}_${DATATYPE}_mask thresh_roi_${ROI}_${DATATYPE}
RANGE=`fslstats thresh_roi_${ROI}_${DATATYPE}.nii.gz -R`
if [ "$RANGE" == "0.000000 0.000000 " ]; then 
	echo "i am empty"
	rm thresh_roi_${ROI}_${DATATYPE}.nii.gz
else
	mv thresh_roi_${ROI}_${DATATYPE}.nii.gz ${OUTPUTDIR}/.
fi
rm roi_${ROI}_${DATATYPE}_perm_upper.nii.gz
rm roi_${ROI}_${DATATYPE}_perm_lower.nii.gz
rm roi_${ROI}_${DATATYPE}_real_above_upper.nii.gz
rm roi_${ROI}_${DATATYPE}_real_below_lower.nii.gz
rm roi_${ROI}_${DATATYPE}_mask.nii.gz

OUTDIR=$MAINDIR/Logs



mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
#rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
