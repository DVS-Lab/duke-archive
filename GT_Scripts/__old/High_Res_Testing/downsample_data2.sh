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

cd $EXPERIMENT/Analysis/HighRes_GT/files_to_use
# fslcpgeom mask_from_otto.nii.gz rand_all_data.nii.gz -d


# I'm using the subsamp2offc option to prevent interpolation, especially along the z-axis

#make masks
fslmaths mask_from_data.nii.gz -bin mask_from_data_char -odt char
fslmaths mask_from_data.nii.gz -subsamp2offc -bin downsampled_mask_from_data_offcenter_char -odt char
fslmaths slice_z16.nii.gz -bin slice_z16_char -odt char
fslmaths slice_z16.nii.gz -subsamp2offc -bin downsampled_slice_z16_offcenter_char -odt char


#from downsample_data.sh -- handles the data only
fslmaths all_data.nii.gz -bin all_data_short -odt short #added -bin to really binarise
fslmaths all_data.nii.gz -subsamp2offc -bin downsampled_all_data_offcenter_short -odt short #added -bin to really binarise
#fslmaths rand_all_data.nii.gz rand_all_data_float -odt float
#fslmaths rand_all_data.nii.gz -subsamp2offc downsampled_rand_all_data_offcenter_float -odt float

fslmaths downsampled_all_data_offcenter_short -mul .0001 downsampled_all_data_offcenter_short_p0001
fslmaths downsampled_all_data_offcenter_short -mul .001 downsampled_all_data_offcenter_short_p001
fslmaths downsampled_all_data_offcenter_short -mul .01 downsampled_all_data_offcenter_short_p01
fslmaths downsampled_all_data_offcenter_short -mul .1 downsampled_all_data_offcenter_short_p1
fslmaths downsampled_all_data_offcenter_short -mul .5 downsampled_all_data_offcenter_short_p5
fslmaths downsampled_all_data_offcenter_short -mul 10 downsampled_all_data_offcenter_short_10
fslmaths downsampled_all_data_offcenter_short -mul 50 downsampled_all_data_offcenter_short_50
fslmaths downsampled_all_data_offcenter_short -mul 100 downsampled_all_data_offcenter_short_100
fslmaths downsampled_all_data_offcenter_short -mul 1000 downsampled_all_data_offcenter_short_1000
fslmaths downsampled_all_data_offcenter_short -mul 10000 downsampled_all_data_offcenter_short_10000


OUTDIR=$EXPERIMENT/Analysis/HighRes_GT


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
