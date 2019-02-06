#!/bin/sh

SPLIT=$1


# #need to assign run numbers
for SUBJ in `cat 120516_IG02_OverlapRestMID_split${SPLIT}.txt`; do

	qsub -v EXPERIMENT=Imagene.02 extraction2.sh $SUBJ
	sleep 1s
done

