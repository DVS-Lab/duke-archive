#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

#########user section#########################
#user specific constants
username = "smith"             		#your cluster login name (use what shows up in qstatall)

classifiers = [ 'LinearNuSVMC', 'RbfNuSVMC' ]
combos = [ "3" ]
ID = "0"
repeats = ['1', '2', '3', '4', '5']
#masks = [ "old" ]
#combos = [ "2" ]



#neglect_combo2_LinearCSVMC_old_CV_performance_rawdata_missingROIs.txt
#neglect_combo2_LinearNuSVMC_old_CV_performance_rawdata_missingROIs.txt
#neglect_combo2_SMLR_old_CV_performance_rawdata_missingROIs.txt


#------START SCRIPT HERE----------------
for repeat in repeats:
	for combo in combos:
		for classifier in classifiers:
			comboN = int(combo)
			
			if comboN > 1:
				#/home/smith/Imagene.02/neglect_mvpa/nperlabel_equal
				fname = ("/home/%s/Imagene.02/neglect_mvpa/nperlabel_equal/neglect_vox_%s_CV_performance_normeddata_rep%s_missingROIs.txt") % (username,classifier,repeat)
				if os.path.isfile(fname):
					combo_f = open(fname,"r")
					combo_list = combo_f.readlines()
					combo_f.close()
				
				
				ROIs = []
				NLoops = 12
				for line in combo_list:
					c = line.split()
					ROIname = "_".join(c)
					ROIs.append(ROIname)
				
				if comboN == 2:
					dummyROI = "000_000"
				elif comboN == 3:
					dummyROI = "000_000_000"
				elif comboN == 4:
					dummyROI = "000_000_000_000"
				
				NROIs = len(ROIs)
				no_mod = NROIs%NLoops
				while no_mod:
					ROIs.append(dummyROI)
					NROIs = len(ROIs)
					no_mod = NROIs%NLoops
				
				
				
				#ROI_array = array(ROIs)
				#sROI_array = ROI_array.reshape(len(ROI_array)/NLoops,NLoops)
				
				counter = 0
				loops = 0
				tmp = []
				for ROI in ROIs:
					counter = counter + 1
					if counter == 1:
						tmp = []
						#print "\ngot to first loop..."
				
					#print ROI
					tmp.append(ROI)
					if counter == NLoops:
						loops = loops + 1
						loop_str = str(loops)
						loop_str = loop_str.zfill(5)
						make_ROI_str = "ROI_set_" + loop_str + " = tmp"
						exec(make_ROI_str)
						counter = 0
			
				N_vars = len(ROIs)/NLoops
			else:
				N_vars = 1
			
			
			for i in range(1,N_vars+1):
				i_str = str(i)
				i_str = i_str.zfill(5)
				if comboN > 1:
					tmp = eval("ROI_set_" + i_str)
					ROI_str = "[ "
					X = len(tmp)
					for idx, ROI in enumerate(tmp):
						#print idx, X
						if (idx+1) == X:
							ROI_str = ROI_str + "'" + ROI + "'" + " ]"
						else:
							ROI_str = ROI_str + "'" + ROI + "'"  + ", "
				else:
					ROI_str = "000"
			
			
				
				print ROI_str
