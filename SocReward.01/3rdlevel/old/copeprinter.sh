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

MAINOUTPUT=${MAINDIR}/3rd_level_copes/MODEL4-TD_averse_flame1_s19
ANALYZED=${MAINOUTPUT}

mkdir -p ${MAINOUTPUT}


for LIST in "hot 17" "neutralf 18" "not 19" "gain 20" "neutralm 21" "loss 22"; do

set -- $LIST #parses list
CON_NAME=$1
RUN=$2




OUTPUT=${MAINOUTPUT}/COPE${RUN}_${CON_NAME}


INPUT01=${MAINDIR}/33754_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT02=${MAINDIR}/33642_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT03=${MAINDIR}/32953_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT04=${MAINDIR}/32958_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT05=${MAINDIR}/32976_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT06=${MAINDIR}/32984_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT07=${MAINDIR}/33035_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT08=${MAINDIR}/33045_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT09=${MAINDIR}/33771_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT10=${MAINDIR}/33082_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT11=${MAINDIR}/33135_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT12=${MAINDIR}/33757_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT13=${MAINDIR}/33302_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT14=${MAINDIR}/33402_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT15=${MAINDIR}/33456_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT16=${MAINDIR}/33467_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT17=${MAINDIR}/33732_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT18=${MAINDIR}/33744_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
INPUT19=${MAINDIR}/33746_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
#INPUT20=${MAINDIR}/33754_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
#INPUT21=${MAINDIR}/33757_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat
#INPUT22=${MAINDIR}/33771_2nd_lvl_model4_td_denoised.gfeat/cope${RUN}.feat

 
echo $OUTPUT
 
echo $INPUT01
echo $INPUT02
echo $INPUT03
echo $INPUT04
echo $INPUT05
echo $INPUT06
echo $INPUT07
echo $INPUT08
echo $INPUT09
echo $INPUT10
echo $INPUT11
echo $INPUT12
echo $INPUT13
echo $INPUT14
echo $INPUT15
echo $INPUT16
echo $INPUT17
echo $INPUT18
echo $INPUT19




done




