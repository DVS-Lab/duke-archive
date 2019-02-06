#!/bin/sh

SPLIT=$1


# #need to assign run numbers
for SUBJ in `cat List${SPLIT}.txt`; do

	qsub -v EXPERIMENT=Imagene.02 extractTPJ.sh $SUBJ
	sleep 1s
done

