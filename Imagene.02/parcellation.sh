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



MAINDIR=${EXPERIMENT}/Analysis/TaskData


cd ${MAINDIR}/StrParc

s=$1 #1, 2
t=$2 #noTask_m05, noTask_m04, wTask

#10 dims
melodic -i str_scripts/str_list${s}_6mm_clean_all_${t}.txt -o gica_s${s}_6mm_clean_all_10dim_${t}.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d 10 --mmthresh=0.5 --Ostats -a concat

sh leech12_dual_regression gica_s${s}_6mm_clean_all_10dim_${t}.ica/melodic_IC 1 -1 0 gica_s${s}_6mm_clean_all_10dim_${t}.ica/DR_output striatum_3p0iso `cat str_scripts/str_list${s}_6mm_clean_all_${t}.txt` _ `cat str_scripts/wb_list${s}_6mm_clean_all_${t}.txt`


#15 dims
melodic -i str_scripts/str_list${s}_6mm_clean_all_${t}.txt -o gica_s${s}_6mm_clean_all_15dim_${t}.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d 15 --mmthresh=0.5 --Ostats -a concat

sh leech12_dual_regression gica_s${s}_6mm_clean_all_15dim_${t}.ica/melodic_IC 1 -1 0 gica_s${s}_6mm_clean_all_15dim_${t}.ica/DR_output striatum_3p0iso `cat str_scripts/str_list${s}_6mm_clean_all_${t}.txt` _ `cat str_scripts/wb_list${s}_6mm_clean_all_${t}.txt`


#05 dims
melodic -i str_scripts/str_list${s}_6mm_clean_all_${t}.txt -o gica_s${s}_6mm_clean_all_05dim_${t}.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d 5 --mmthresh=0.5 --Ostats -a concat

sh leech12_dual_regression gica_s${s}_6mm_clean_all_05dim_${t}.ica/melodic_IC 1 -1 0 gica_s${s}_6mm_clean_all_05dim_${t}.ica/DR_output striatum_3p0iso `cat str_scripts/str_list${s}_6mm_clean_all_${t}.txt` _ `cat str_scripts/wb_list${s}_6mm_clean_all_${t}.txt`


#00 dims
melodic -i str_scripts/str_list${s}_6mm_clean_all_${t}.txt -o gica_s${s}_6mm_clean_all_00dim_${t}.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d 0 --mmthresh=0.5 --Ostats -a concat

sh leech12_dual_regression gica_s${s}_6mm_clean_all_00dim_${t}.ica/melodic_IC 1 -1 0 gica_s${s}_6mm_clean_all_00dim_${t}.ica/DR_output striatum_3p0iso `cat str_scripts/str_list${s}_6mm_clean_all_${t}.txt` _ `cat str_scripts/wb_list${s}_6mm_clean_all_${t}.txt`



OUTDIR=${MAINDIR}/Logs/parcellation
mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
