#!/bin/bash

for x in 1 2; do
	for i in `cat list${x}_RestingMID_subs.txt`; do
		qsub -v EXPERIMENT=Imagene.02 StrParcPPI.sh $i $x 4
		sleep 7s
	done
done
