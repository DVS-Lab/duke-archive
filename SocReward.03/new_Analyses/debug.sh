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


MAINDIR=${EXPERIMENT}/Analysis/FSL
FILENAME=${MAINDIR}/34712/Active/PreStatsOnly/Smooth_6mm/run1.feat

dos2unix $FILENAME/design.fsf
func_smoothing=`grep "fmri(smooth)" $FILENAME/design.fsf | tail -n 1 | awk '{print $3}'`
standard_space_resolution=`${FSLDIR}/bin/fslval $FILENAME/reg/standard pixdim1`
struc_smoothing=`${FSLDIR}/bin/match_smoothing $FILENAME/example_func $func_smoothing $FILENAME/reg/highres $standard_space_resolution`

echo $struc_smoothing


echo "display func smoothing and std space res..."
echo $func_smoothing
echo $standard_space_resolution


# OUT=`${FSLDIR}/bin/remove_ext $1`
# shift
# 
# # estimate how much we will need to smooth the structurals by, in the end
# echo Estimating smoothness of functional data...
# func_smoothing=`grep "fmri(smooth)" $1/design.fsf | tail -n 1 | awk '{print $3}'`
# standard_space_resolution=`${FSLDIR}/bin/fslval $1/reg/standard pixdim1`
# struc_smoothing=`${FSLDIR}/bin/match_smoothing $1/example_func $func_smoothing $1/reg/highres $standard_space_resolution`
# echo Structural-space GM PVE images will be smoothed by sigma=${struc_smoothing}mm to match the standard-space functional data
# 
# # run segmentations, smoothing, and standard-space transformation
# CWD=`pwd`
# /bin/rm -rf ${OUT}.log
# mkdir ${OUT}.log
# for f in $@ ; do
#   printf "cd ${f}/reg; $FSLDIR/bin/fast -R 0.3 -H 0.1 -o grot highres; $FSLDIR/bin/immv grot_pve_2 highresGM; /bin/rm grot*; $FSLDIR/bin/fslmaths highresGM -s $struc_smoothing highresGMs; " >> ${OUT}.log/featseg1
#   if [ `${FSLDIR}/bin/imtest ${f}/reg/highres2standard_warp` = 1 ] ; then
#       printf "${FSLDIR}/bin/applywarp --ref=standard --in=highresGMs --out=highresGMs2standard --warp=highres2standard_warp; " >> ${OUT}.log/featseg1
#   else
#       printf "${FSLDIR}/bin/flirt -in highresGMs -out highresGMs2standard -ref standard -applyxfm -init highres2standard.mat; " >> ${OUT}.log/featseg1
#   fi 
#   echo "cd $CWD" >> ${OUT}.log/featseg1
#   GMlist="$GMlist ${f}/reg/highresGMs2standard"
# done
# chmod a+x ${OUT}.log/featseg1
# echo Running segmentations...
# featseg1_id=`$FSLDIR/bin/fsl_sub -T 30 -N featseg1 -l ./${OUT}.log -t ./${OUT}.log/featseg1`
# 
# # concatenate and de-mean GM images
# echo "${FSLDIR}/bin/fslmerge -t $OUT $GMlist; ${FSLDIR}/bin/fslmaths $OUT -Tmean -mul -1 -add $OUT $OUT" > ${OUT}.log/featseg2
# echo Running concatenation of all standard space GM images
# $FSLDIR/bin/fsl_sub -T 10 -N featseg2 -l ./${OUT}.log -j $featseg1_id -t ./${OUT}.log/featseg2 > /dev/null
# 
# echo "Once this is all complete you may want to add additional smoothing to $OUT in order to ameliorate possible effects of mis-registrations between functional and structural data, and to lessen the effect of the additional confound regressors"


OUTDIR=${EXPERIMENT}/Analysis/FSL/VBM_covariate_debug
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
