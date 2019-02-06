#!/usr/bin/env python
import sys,os,smtplib
 
useremail="sl139@duke.edu"
 
f_name=sys.argv[1] #Get name of newly created template file
subject=sys.argv[2]
f=open(f_name)
template=f.readlines()
f.close()
 
for line in template:
	#Get FSL Analysis Level
	if line.find('set fmri(level)')==0:
		temp=line.split()
		for i in temp:
			if i.isdigit():
				analysis_level=int(i)
	#Get the number of runs
	elif line.find('set fmri(multiple)')==0:
		temp=line.split()
		for i in temp:
			if i.isdigit():
				numruns=int(i)
	#Get the number of EV's included
	elif line.find('set fmri(evs_orig)')==0:
		temp=line.split()
		for i in temp:
			if i.isdigit():
				numevs=int(i)
				
bad_files={} #Makes a dictionary of all bad files
count=0 #Counts the number of bad files
 
#Check the paths for all Input Data
for run in range(1,numruns+1):
	for line in template:
		if line.find('set feat_files('+str(run))==0:
			temp=line.split()
			temp=temp[2]
			temp=temp.strip('"')
			if os.path.exists(temp):
				if analysis_level==1:
					pipe=os.popen("fslinfo "+temp)
					act_npts=pipe.readlines()
					pipe.close()
					act_npts=act_npts[4].split()
					act_npts=int(act_npts[1])
					for line in template:
						if line.find('set fmri(npts)')==0:
							npts=line.split()
							npts=int(npts[2])
					if act_npts!=npts:
						bad_files[count]="TIMEPOINTS DON'T MATCH!!! Template: %s Data: %s" % (str(npts),str(act_npts))
						count=count+1
				continue
			else:
				bad_files[count]='Input'+str(run)+': '+temp
				count=count+1
 
#Check Anatomical path if needed
for line in template:
	if line.find('set highres_files(1)')==0:
		temp=line.split()
		temp=temp[2]
		temp=temp.strip('"')
		if os.path.isfile(temp):
			continue
		else:
			bad_files[count]='Anatomical: '+temp
			count=count+1
			
#Check EV file paths if First Level Analysis
if analysis_level==1:
	for ev in range(1,numevs+1):
		for line in template:
			if line.find('set fmri(custom'+str(ev))==0:
				temp=line.split()
				temp=temp[2]
				temp=temp.strip('"')
				if os.path.isfile(temp):
					fname=file(temp)
					f=fname.readlines()
					fname.close()
					if len(f)>0:
						continue
					else:
						bad_files[count]='EV File #'+str(ev)+' is empty: '+temp
				else:
					bad_files[count]='EV file # '+str(ev)+' does not exist: '+temp
					count=count+1
 
if len(bad_files)==0:
	print "Running FEAT"
	os.system('feat '+f_name) #No bad files so run FEAT job
else:
	text= "Your FEAT job did not submit because the following are incorrect paths or other errors with subject %s:\r\n" % (str(subject))
	print text
	for i in range(len(bad_files)):
		print bad_files[i] #Print bad files to cluster log
		text=text+bad_files[i]+'\r\n'
		
	#Send out an email telling you job did not run
	serverURL="email.biac.duke.edu"
	headers="From: %s\r\nTo: %s\r\nSubject: FEAT did not run!\r\n\r\n" % (useremail,useremail)
	message=headers+text
	mailServer=smtplib.SMTP(serverURL)
	mailServer.sendmail(useremail,useremail,message)
	mailServer.quit()