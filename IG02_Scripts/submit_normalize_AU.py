#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

#listname = sys.argv[1]

fname = "/home/smith/Imagene.02/task_firstruns.txt"

#print " "
#print " "
#print " "

if os.path.isfile(fname):
	input_f = open(fname,"r")
	input_list = input_f.readlines()
	input_f.close()

#In [13]: print c[0], c[1], c[2]
#10168 Risk 1

#In [14]: print c[3], c[4], c[5]
#10181 Risk 1

	for line in input_list:
		c = line.split()
		nlines = len(c)/3;
		mylines = range(0,nlines)
		for myline in mylines:
			subj = c[(myline*3)]
			task = c[(myline*3)+1]
			run = c[(myline*3)+2]
			#print subj, task, run
			
			#pngfile = ("/home/smith/Imagene.02/FNIRT_redos/%s_run%s_%s.png") % (str(subj),str(run),str(task))
			#if not os.path.isfile(pngfile):
			#	continue

			cmd = "qsub -v EXPERIMENT=Imagene.02 normalize_AU.sh %s %s %s"  % ( subj, task, run )
			if task == "MID":
				dummy, f = os.popen2(cmd)
				print(cmd)
				time.sleep(1)

	#qsub -v EXPERIMENT=Imagene.02 normalize_AU.sh ${SUBJ} ${GO}
	#sleep 10s

#sleep 25m
