#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

username = "smith"             		#your cluster login name (use what shows up in qstatall)

datatypes = [ "raw", "normed" ]
testnames = [ "neglect", "size" ]
classifiers = ['SMLR', 'LinearNuSVMC', 'LinearCSVMC' ]
masks = [ "old", "new" ]
combo = "3"


#------START SCRIPT HERE----------------
xx = 0
for datatype in datatypes:
	for classifier in classifiers:
		for mask in masks:
			for testname in testnames:
				comboN = int(combo)
				fname = ("/home/%s/Imagene.02/neglect_mvpa/redos/%s_combo%s_%s_%s_CV_performance_%sdata_missingROIs.txt") % (username,testname,combo,classifier,mask,datatype)
				if os.path.isfile(fname):
					combo_f = open(fname,"r")
					combo_list = combo_f.readlines()
					combo_f.close()
				#else:
				#	continue
				
				xx = xx + 1
				print xx