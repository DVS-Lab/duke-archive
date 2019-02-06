#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib
import numpy as N

listname = sys.argv[1]
taskname = sys.argv[2]

fname = ("/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis/avu/%s") % (listname)
print " "
print " "

if os.path.isfile(fname):
	input_f = open(fname,"r")
	input_list = input_f.readlines()
	input_f.close()

	data_array = N.zeros((len(input_list),2))
	for i, line in enumerate(input_list):
		c = line.split()
		subj = c[0]
		run = c[1]
		data_array[i,0] = int(subj)
		data_array[i,1] = int(run)
		
		datafile  = ("/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis/avu/Social_nonSoc_ant/%s/run%s/FEAT/social_nonsocial_anticipation.feat/stats/cope1.nii.gz") %(subj, run)
		print datafile
	  
	print " "
	print " "
	print " "
		

else:
	print "could not find file"
