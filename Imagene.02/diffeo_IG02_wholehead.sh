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

MAINDIR=${EXPERIMENT}/Analysis/ANTS

SMOOTH=0
GO=1
RUN=2


SUBJECTS=( 10156 10168 10181 10199 10255 10256 10264 10265 10279 10280 10281 10286 10287 10294 10304 10305 10306 10314 10315 10335 10350 10351 10352 10358 10359 10360 10387 10414 10415 10416 10424 10425 10426 10471 10472 10474 10481 10482 10483 10512 10515 10521 10523 10524 10525 10558 10560 10565 10583 10602 10605 10615 10657 10659 10665 10670 10696 10697 10698 10699 10705 10706 10707 10746 10747 10749 10757 10762 10782 10783 10785 10793 10794 10795 10817 10827 10844 10845 10858 10890 11021 11022 11024 11029 11058 11059 11065 11066 11067 11171 11176 11196 11209 11210 11212 11215 11216 11217 11232 11233 11235 11243 11244 11245 11264 11266 11272 11273 11274 11291 11292 11293 11326 11327 11328 11335 11363 11364 11366 11371 11372 11373 11383 11393 11394 11402 11430 11473 11479 11511 11525 11545 11578 11584 11602 11605 11625 11659 11660 11692 11738 11762 11778 11805 11865 11878 11941 11950 12015 12071 12082 12089 12097 12132 12159 12165 12175 12176 12217 12235 12277 12280 12294 12314 12360 12372 12380 12383 12393 12400 12411 12412 12444 12459 12460 12476 12496 12541 12550 12551 12564 12580 12596 12606 12614 12629 12664 12665 12677 12678 12679 12691 12711 12717 12731 12742 12755 12756 12757 12758 12766 12768 12780 12789 12791 12802 12815 12816 12817 12828 12839 12840 12850 12873 12874 12875 12879 12880 12893 12894 12896 12905 12907 12911 12923 12960 12961 12988 12989 13011 13051 13060 )



OUTPUTDIR=$TMPDIR/T1s_2mm_wholehead_ANTS
cp -r $MAINDIR/T1s_2mm_wholehead $TMPDIR/T1s_2mm_wholehead_ANTS


#FNIRT will want a whole head and a BETed image. making whole head later (see below)
STANDARD=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz
LENGTH=${#SUBJECTS[@]}
let LENGTH=$LENGTH-1

TYPE=wholehead
TMPOUTPREFIX=all_T1s
OUTPREFIX=mean_TI
FLIRTOUTEXT=T1

N=0
for x in `seq 0 $LENGTH`; do
	let N=$N+1
	SUBJ=${SUBJECTS[$x]}

	FLIRTIN=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/${SUBJ}_anat.nii.gz
	FLIRTOUT=${OUTPUTDIR}/${SUBJ}_${FLIRTOUTEXT}_${TYPE}.nii.gz
	INMAT=${OUTPUTDIR}/${SUBJ}_${FLIRTOUTEXT}_brain.mat #from previous analysis

	#flirt -ref $STANDARD -in $FLIRTIN -out $FLIRTOUT -omat $OUTMAT -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear
	flirt -ref $STANDARD -in $FLIRTIN -out $FLIRTOUT -applyxfm -init $INMAT -interp trilinear

done


cd $OUTPUTDIR
fslmerge -t ${TMPOUTPREFIX}_n${N}_${TYPE} *.nii.gz
fslmaths ${TMPOUTPREFIX}_n${N}_${TYPE} -Tmean ${OUTPREFIX}_n${N}_${TYPE}
rm -rf ${TMPOUTPREFIX}_n${N}_${TYPE}.nii.gz

mv ${OUTPREFIX}_n${N}_${TYPE}.nii.gz ${MAINDIR}/${OUTPREFIX}_n${N}_${TYPE}.nii.gz

#sh ./buildtemplateparallel.sh -d 3 -c 1 -o w -n 0 -i 5   -z /home/crlab/dukeants/template.nii.gz  $m*.nii.gz
#sh $ANTSPATH/buildtemplateparallel.sh -d 3 -c 2 -j 2 -o w -n 0 -i 5 -z $MAINDIR/${OUTPREFIX}_n${N}_${TYPE}.nii.gz *_${FLIRTOUTEXT}_${TYPE}.nii.gz
#sh $ANTSPATH/buildtemplateparallel.sh -d 3 -c 2 -j 2 -o w -n 0 -i 5 *_${FLIRTOUTEXT}_${TYPE}.nii.gz
sh ${ANTSPATH}buildtemplateparallel.sh -d 3 -c 0 -o diffeo -n 0 -i 5 *_wholehead.nii.gz

mv ${OUTPUTDIR} ${MAINDIR}/.

OUTDIR=$MAINDIR/Logs
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
