#!/bin/sh

#echo "sleeping for 10 minutes at `date`"
#sleep 10m

for SUBJ in 1002 1006 1005 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1032 1033 1034 1035 1036 1037 1038 1039; do

	qsub -v EXPERIMENT=HighRes.01 cleanup.sh $SUBJ
	sleep 5s

done