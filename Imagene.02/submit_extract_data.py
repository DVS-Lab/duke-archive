#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

fname = "/home/dvs3/linux/Imagene.02/in_list.txt"

if os.path.isfile(fname):
	input_f = open(fname,"r")
	input_list = input_f.readlines()
	input_f.close()


	for line in input_list:
		c = line.split()
		nlines = len(c)/3;
		mylines = range(0,nlines)
		for myline in mylines:
			subj = c[(myline*3)]
			task = c[(myline*3)+1]
			run = c[(myline*3)+2]

			cmd = "qsub -v EXPERIMENT=Imagene.02 extract_data.sh %s %s %s"  % ( subj, task, run )
	
			dummy, f = os.popen2(cmd)
			print(cmd)
			time.sleep(5)
			
			
