#/bin/sh

for s in `cat resting_n178.txt`; do
	qsub -v EXPERIMENT=Imagene.02 resting.sh $s
	sleep 10s
done
