#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib


splits = [ '2' ]
maindir = '/home/dvs3/linux/Imagene.02'

for split in splits:
	fname = '%s/list%s_runs_edit2_resting.txt'  % ( maindir, split )
	if os.path.isfile(fname):
		input_f = open(fname,'r')
		input_list = input_f.readlines()
		input_f.close()

		for line in input_list:
			c = line.split()
			nlines = len(c)/2;
			mylines = range(0,nlines)
			for myline in mylines:
				subnum = c[(myline*3)]
				run = c[(myline*3)+1]
				if int(subnum) <= int(10706): 
					continue
				
				print subnum
				

