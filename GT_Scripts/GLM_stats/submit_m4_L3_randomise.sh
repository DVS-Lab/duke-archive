#!/bin/sh


for LIST in "2 Face-Land" "3 Land-Face" "10 FaceH-FaceL" "11 LandH-LandL" "12 Land_U" "13 Face_U" "14 FaceM-FaceL" "15 LandM-LandL" "16 FaceH-FaceM" "17 LandH-LandM" "18 interaction" "19 high-low" "20 high-med" "21 med-low" "22 U_pos"; do
	set -- $LIST
	CNUM=$1
	CNAME=$2
	qsub -v EXPERIMENT=HighRes.01 m4_L3_randomise.sh $CNUM $CNAME
	sleep 10s
done


