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


ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/HighRes.01
sleep 5s


SUBJ=SUB_SUBNUM_SUB
RUN=SUB_RUN_SUB
SMOOTH=0
GO=SUB_GO_SUB


MAINDIR=${EXPERIMENT}/Analysis
MAINOUTPUT=${MAINDIR}/FSL/BadVolumePNGs
mkdir -p ${MAINOUTPUT}
DATA=$MAINDIR/NIFTI/${SUBJ}/fMRIphysio${RUN}new${SUBJ}.nii.gz
PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats/Smooth_${SMOOTH}mm/run${RUN}.feat

# #${PRESTATSDIR}/bad_timepoints.txt #should try to integrate this into the script so that it only makes the PNGs for the bad volumes


rm -rf ${PRESTATSDIR}/tmp_*
cd ${PRESTATSDIR}
for i in `cat bad_list.txt`; do
	I=`zeropad $i 4`
	if [ ! -e ${MAINOUTPUT}/${SUBJ}run${RUN}badvol${I}_2_examplefunc.png ]; then
		fslroi $DATA tmp_${I} $i 1
		$FSLDIR/bin/slicer tmp_${I} example_func -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png
		$FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png tmp${I}_2_examplefunc1.png
		$FSLDIR/bin/slicer example_func tmp_${I} -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png
		$FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png tmp${I}_2_examplefunc2.png
		$FSLDIR/bin/pngappend tmp${I}_2_examplefunc1.png - tmp${I}_2_examplefunc2.png ${MAINOUTPUT}/${SUBJ}run${RUN}badvol${I}_2_examplefunc.png
		/bin/rm -f sl?.png
		/bin/rm -f tmp${I}_2_examplefunc?.png
		/bin/rm -f tmp_${I}.nii.gz
	else
		echo "found previous output..."
	fi	
done
OUTDIR=${MAINDIR}/FSL/Logs/badvolume_pngs
mkdir -p $OUTDIR




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
