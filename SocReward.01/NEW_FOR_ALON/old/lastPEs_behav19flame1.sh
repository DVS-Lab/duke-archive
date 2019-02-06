#!/bin/bash


# Generate a sequence from m to n, m defaults to 1.

seq ()
{
	declare -i lo hi i	# makes local
	local _SEQ

	case $# in
	1) seq 1 "$1" ; return $? ;;
	2) lo=$1 hi=$2
	   i=$lo _SEQ=""
	   while let "i <= hi"; do
		_SEQ="${_SEQ}$i "
		let i+=1
	   done
	   echo "${_SEQ# }"
	   return 0 ;;
	*) echo seq: usage: seq [low] high 1>&2 ; return 2 ;;
	esac
}

# like the APL `iota' function (or at least how I remember it :-)
iota()
{
	case $# in
	1) seq 1 "$1"; return $?;;
	*) echo "iota: usage: iota high" 1>&2; return 2;;
	esac
}




# "32953 5" "32958 5" "32976 5" "32984 5" "33035 5" "33045 5" "33064 5" "33082 5" "33135 5"




MAINDIR=/mnt/hgfs/data/SocReward.01/Analysis/FSL/HIGHER_LEVEL

MAINOUTPUT=${MAINDIR}/3rd_level_copes/MODEL4-TD_behav_flame1_s19
ANALYZED=${MAINOUTPUT}

mkdir -p ${MAINOUTPUT}


for LIST in "hot 17" "neutralf 18" "not 19" "gain 20" "neutralm 21" "loss 22"; do

set -- $LIST #parses list
CON_NAME=$1
RUN=$2




OUTPUT=${MAINOUTPUT}/COPE${RUN}_${CON_NAME}


INPUT01=${MAINDIR}/33754_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT02=${MAINDIR}/33642_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT03=${MAINDIR}/32953_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT04=${MAINDIR}/32958_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT05=${MAINDIR}/32976_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT06=${MAINDIR}/32984_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT07=${MAINDIR}/33035_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT08=${MAINDIR}/33045_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT09=${MAINDIR}/33771_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT10=${MAINDIR}/33082_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT11=${MAINDIR}/33135_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT12=${MAINDIR}/33757_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT13=${MAINDIR}/33302_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT14=${MAINDIR}/33402_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT15=${MAINDIR}/33456_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT16=${MAINDIR}/33467_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT17=${MAINDIR}/33732_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT18=${MAINDIR}/33744_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
INPUT19=${MAINDIR}/33746_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
#INPUT20=${MAINDIR}/33754_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
#INPUT21=${MAINDIR}/33757_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz
#INPUT22=${MAINDIR}/33771_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat/stats/cope1.nii.gz

 

 echo $OUTPUT
 for i in 'behav_s19_flame1.fsf'; do
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
   -e 's@INPUT11@'$INPUT11'@g' \
   -e 's@INPUT12@'$INPUT12'@g' \
   -e 's@INPUT13@'$INPUT13'@g' \
   -e 's@INPUT14@'$INPUT14'@g' \
   -e 's@INPUT15@'$INPUT15'@g' \
   -e 's@INPUT16@'$INPUT16'@g' \
   -e 's@INPUT17@'$INPUT17'@g' \
   -e 's@INPUT18@'$INPUT18'@g' \
   -e 's@INPUT19@'$INPUT19'@g' <$i> ${ANALYZED}/3rdLvlFixed_${RUN}_${CON_NAME}.fsf
 done
    
   
 #runs the analysis using the newly created fsf file
 feat ${ANALYZED}/3rdLvlFixed_${RUN}_${CON_NAME}.fsf


done




