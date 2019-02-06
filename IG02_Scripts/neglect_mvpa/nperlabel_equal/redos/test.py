#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

#########user section#########################
#user specific constants
username = "smith"             		#your cluster login name (use what shows up in qstatall)
datatypes = [ "raw", "normed" ]
classifiers = ['LinearNuSVMC', 'RbfNuSVMC' ]
masks = [ "old", "new" ]


#------START SCRIPT HERE----------------
for datatype in datatypes:
	for classifier in classifiers:
		for mask in masks:
			#/home/smith/Imagene.02/neglect_mvpa/nperlabel_equal
			fname = ("/home/%s/Imagene.02/neglect_mvpa/nperlabel_equal/redos/perm_WB_%s_mask_CV_%s_performance_%sdata_missing.txt") % (username,mask,classifier,datatype)
			if os.path.isfile(fname):
				combo_f = open(fname,"r")
				combo_list = combo_f.readlines()
				combo_f.close()
			else:
				continue
			
			for line in combo_list:
				c = line.split()
				print c[0], c[1]

