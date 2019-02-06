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
#$ -m ea

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
#$ -M dvs3@duke.edu


# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


cd ${EXPERIMENT}/Analysis/TaskData/StrParc
D=$1
Dnum=$D

D=`zeropad $D 2`


#melodic -i str_scripts/str_4mm_RestingMID.txt -o gica_RestMID_4mm_${D}dim_all.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d $Dnum --mmthresh=0.5 --Ostats -a concat

#sh leech12_dual_regression gica_RestMID_4mm_${D}dim_all.ica/melodic_IC 1 -1 0 gica_RestMID_4mm_${D}dim_all.ica/DR_task1 striatum_3p0iso `cat str_scripts/str_list1_4mm_clean_all_RestMID.txt` _ `cat str_scripts/wb_list1_4mm_clean_all_RestMID.txt`
#sh leech12_dual_regression gica_RestMID_4mm_${D}dim_all.ica/melodic_IC 1 -1 0 gica_RestMID_4mm_${D}dim_all.ica/DR_task2 striatum_3p0iso `cat str_scripts/str_list2_4mm_clean_all_RestMID.txt` _ `cat str_scripts/wb_list2_4mm_clean_all_RestMID.txt`

#sh leech12_dual_regression gica_RestMID_4mm_${D}dim_all.ica/melodic_IC 1 -1 0 gica_RestMID_4mm_${D}dim_all.ica/DR_rest1 striatum_3p0iso `cat str_scripts/str_list1_4mm_clean_all_Rest_only.txt` _ `cat str_scripts/wb_list1_4mm_clean_all_Rest_only.txt`
#sh leech12_dual_regression gica_RestMID_4mm_${D}dim_all.ica/melodic_IC 1 -1 0 gica_RestMID_4mm_${D}dim_all.ica/DR_rest2 striatum_3p0iso `cat str_scripts/str_list2_4mm_clean_all_Rest_only.txt` _ `cat str_scripts/wb_list2_4mm_clean_all_Rest_only.txt`

#melodic -i str_scripts/str_list1_4mm_clean_all_Rest_only.txt -o gica_Rest_4mm_${D}dim_all_split1.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d $Dnum --mmthresh=0.5 --Ostats -a concat
#melodic -i str_scripts/str_list2_4mm_clean_all_Rest_only.txt -o gica_Rest_4mm_${D}dim_all_split2.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d $Dnum --mmthresh=0.5 --Ostats -a concat


#sh leech12_dual_regression gica_Rest_4mm_${D}dim_all_split1.ica/melodic_IC 1 -1 0 gica_Rest_4mm_${D}dim_all_split1.ica/DR_task striatum_3p0iso `cat str_scripts/str_list1_4mm_clean_all_RestMID.txt` _ `cat str_scripts/wb_list1_4mm_clean_all_RestMID.txt`
#sh leech12_dual_regression gica_Rest_4mm_${D}dim_all_split2.ica/melodic_IC 1 -1 0 gica_Rest_4mm_${D}dim_all_split2.ica/DR_task striatum_3p0iso `cat str_scripts/str_list2_4mm_clean_all_RestMID.txt` _ `cat str_scripts/wb_list2_4mm_clean_all_RestMID.txt`

#sh leech12_dual_regression gica_Rest_4mm_${D}dim_all_split1.ica/melodic_IC 1 -1 0 gica_Rest_4mm_${D}dim_all_split1.ica/DR_rest striatum_3p0iso `cat str_scripts/str_list1_4mm_clean_all_Rest_only.txt` _ `cat str_scripts/wb_list1_4mm_clean_all_Rest_only.txt`
#sh leech12_dual_regression gica_Rest_4mm_${D}dim_all_split2.ica/melodic_IC 1 -1 0 gica_Rest_4mm_${D}dim_all_split2.ica/DR_rest striatum_3p0iso `cat str_scripts/str_list2_4mm_clean_all_Rest_only.txt` _ `cat str_scripts/wb_list2_4mm_clean_all_Rest_only.txt`



melodic -i str_scripts/str_list1_4mm_clean_conj_Rest_only.txt -o gica_Rest_4mm_${D}dim_conj_split1.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d $Dnum --mmthresh=0.5 --Ostats -a concat
melodic -i str_scripts/str_list2_4mm_clean_conj_Rest_only.txt -o gica_Rest_4mm_${D}dim_conj_split2.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d $Dnum --mmthresh=0.5 --Ostats -a concat


sh leech12_dual_regression gica_Rest_4mm_${D}dim_conj_split1.ica/melodic_IC 1 -1 0 gica_Rest_4mm_${D}dim_conj_split1.ica/DR_task thresh_conj_m07_c5_str `cat str_scripts/str_list1_4mm_clean_conj_RestMID.txt` _ `cat str_scripts/wb_list1_4mm_clean_conj_RestMID.txt`
sh leech12_dual_regression gica_Rest_4mm_${D}dim_conj_split2.ica/melodic_IC 1 -1 0 gica_Rest_4mm_${D}dim_conj_split2.ica/DR_task thresh_conj_m07_c5_str `cat str_scripts/str_list2_4mm_clean_conj_RestMID.txt` _ `cat str_scripts/wb_list2_4mm_clean_conj_RestMID.txt`

sh leech12_dual_regression gica_Rest_4mm_${D}dim_conj_split1.ica/melodic_IC 1 -1 0 gica_Rest_4mm_${D}dim_conj_split1.ica/DR_rest thresh_conj_m07_c5_str `cat str_scripts/str_list1_4mm_clean_conj_Rest_only.txt` _ `cat str_scripts/wb_list1_4mm_clean_conj_Rest_only.txt`
sh leech12_dual_regression gica_Rest_4mm_${D}dim_conj_split2.ica/melodic_IC 1 -1 0 gica_Rest_4mm_${D}dim_conj_split2.ica/DR_rest thresh_conj_m07_c5_str `cat str_scripts/str_list2_4mm_clean_conj_Rest_only.txt` _ `cat str_scripts/wb_list2_4mm_clean_conj_Rest_only.txt`



#WITH TASK

#melodic -i str_scripts/str_list1_4mm_clean_conj_RestMID.txt -o gica_Task_4mm_${D}dim_conj_split1.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d $Dnum --mmthresh=0.5 --Ostats -a concat
#melodic -i str_scripts/str_list2_4mm_clean_conj_RestMID.txt -o gica_Task_4mm_${D}dim_conj_split2.ica -v --bgimage=mean_func_3p0iso --nobet --tr=1.58 --report --guireport=report.html -d $Dnum --mmthresh=0.5 --Ostats -a concat


#sh leech12_dual_regression gica_Task_4mm_${D}dim_conj_split1.ica/melodic_IC 1 -1 0 gica_Task_4mm_${D}dim_conj_split1.ica/DR_task thresh_conj_m07_c5_str `cat str_scripts/str_list1_4mm_clean_conj_RestMID.txt` _ `cat str_scripts/wb_list1_4mm_clean_conj_RestMID.txt`
#sh leech12_dual_regression gica_Task_4mm_${D}dim_conj_split2.ica/melodic_IC 1 -1 0 gica_Task_4mm_${D}dim_conj_split2.ica/DR_task thresh_conj_m07_c5_str `cat str_scripts/str_list2_4mm_clean_conj_RestMID.txt` _ `cat str_scripts/wb_list2_4mm_clean_conj_RestMID.txt`

#sh leech12_dual_regression gica_Task_4mm_${D}dim_conj_split1.ica/melodic_IC 1 -1 0 gica_Task_4mm_${D}dim_conj_split1.ica/DR_rest thresh_conj_m07_c5_str `cat str_scripts/str_list1_4mm_clean_conj_Rest_only.txt` _ `cat str_scripts/wb_list1_4mm_clean_conj_Rest_only.txt`
#sh leech12_dual_regression gica_Task_4mm_${D}dim_conj_split2.ica/melodic_IC 1 -1 0 gica_Task_4mm_${D}dim_conj_split2.ica/DR_rest thresh_conj_m07_c5_str `cat str_scripts/str_list2_4mm_clean_conj_Rest_only.txt` _ `cat str_scripts/wb_list2_4mm_clean_conj_Rest_only.txt`

#sh leech12_dual_regression gica_Task_4mm_${D}dim_conj_split1.ica/melodic_IC 1 -1 0 gica_Task_4mm_${D}dim_conj_split1.ica/DR_XtaskX thresh_conj_m07_c5_str `cat str_scripts/str_list2_4mm_clean_conj_RestMID.txt` _ `cat str_scripts/wb_list2_4mm_clean_conj_RestMID.txt`
#sh leech12_dual_regression gica_Task_4mm_${D}dim_conj_split2.ica/melodic_IC 1 -1 0 gica_Task_4mm_${D}dim_conj_split2.ica/DR_XtaskX thresh_conj_m07_c5_str `cat str_scripts/str_list1_4mm_clean_conj_RestMID.txt` _ `cat str_scripts/wb_list1_4mm_clean_conj_RestMID.txt`





OUTDIR=${EXPERIMENT}/Analysis/TaskData/StrParc/Logs/melodic_new2
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
