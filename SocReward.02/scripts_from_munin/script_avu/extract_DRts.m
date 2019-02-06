
maindir = '/mnt/BIAC/munin4.dhe.duke.edu/Huettel/SocReward.02/Analysis/';

sublist = load(fullfile(maindir, 'avu', 'final_sub_runs_task.txt'));
subs = sublist(:,1);
runs = sublist(:,2);

DR_output = fullfile(maindir, 'avu', 'SR_02_ICA_std', 'DR_output');

for i=1:length(sublist);
	subject = subs(i);
	runnum = runs(i);
	
	SUBJDIR=fullfile(maindir, 'FSL', num2str(subject), 'MELODIC_FLIRT', 'Smooth_5mm', ['run' num2str(runnum) '.ica']);
	DR_file_str = sprintf('%05d', i-1);
	DR_file = fullfile(DR_output, ['dr_stage1_subject' DR_file_str '.txt']);
	
	timecourses = load(fullfile(DR_file));
	
	DMN_ts = timecourses(:,6);
	ECN_ts = timecourses(:,4);
	LFP_ts = timecourses(:,3);
	RFP_ts = timecourses(:,7);
	
	IC1 = timecourses(:,1);
	IC2 = timecourses(:,2);
	IC5 = timecourses(:,5);
	IC8 = timecourses(:,8);
	IC9 = timecourses(:,9);
	IC10 = timecourses(:,10);
	IC11 = timecourses(:,11);
	IC12 = timecourses(:,12);
	IC13 = timecourses(:,13);
	IC14 = timecourses(:,14);
	IC15 = timecourses(:,15);
	IC16 = timecourses(:,16);
	IC17 = timecourses(:,17);
	IC18 = timecourses(:,18);
	IC19 = timecourses(:,19);
	IC20 = timecourses(:,20);
	IC21 = timecourses(:,21);
	IC22 = timecourses(:,22);
	IC23 = timecourses(:,23);
	IC24 = timecourses(:,24);
	IC25 = timecourses(:,25);
	
	DMN_OUT = fullfile(SUBJDIR,'DMN_DR_ts.txt');
	ECN_OUT = fullfile(SUBJDIR,'ECN_DR_ts.txt');
	LFP_OUT = fullfile(SUBJDIR,'LFP_DR_ts.txt');
	RFP_OUT = fullfile(SUBJDIR,'RFP_DR_ts.txt');
	
	dlmwrite(DMN_OUT, DMN_ts,'precision','%.6f');
	dlmwrite(ECN_OUT, ECN_ts,'precision','%.6f');
	dlmwrite(LFP_OUT, LFP_ts,'precision','%.6f');
	dlmwrite(RFP_OUT, RFP_ts,'precision','%.6f');
	
	out1 = fullfile(SUBJDIR, 'IC1_DR_ts.txt');
	out2 = fullfile(SUBJDIR, 'IC2_DR_ts.txt');
	out5 = fullfile(SUBJDIR, 'IC5_DR_ts.txt');
	out8 = fullfile(SUBJDIR, 'IC8_DR_ts.txt');
	out9 = fullfile(SUBJDIR, 'IC9_DR_ts.txt');
	out10 = fullfile(SUBJDIR, 'IC10_DR_ts.txt');
	out11 = fullfile(SUBJDIR, 'IC11_DR_ts.txt');
	out12 = fullfile(SUBJDIR, 'IC12_DR_ts.txt');
	out13 = fullfile(SUBJDIR, 'IC13_DR_ts.txt');
	out14 = fullfile(SUBJDIR, 'IC14_DR_ts.txt');
	out15 = fullfile(SUBJDIR, 'IC15_DR_ts.txt');
	out16 = fullfile(SUBJDIR, 'IC16_DR_ts.txt');
	out17 = fullfile(SUBJDIR, 'IC17_DR_ts.txt');
	out18 = fullfile(SUBJDIR, 'IC18_DR_ts.txt');
	out19 = fullfile(SUBJDIR, 'IC19_DR_ts.txt');
	out20 = fullfile(SUBJDIR, 'IC20_DR_ts.txt');
	out21 = fullfile(SUBJDIR, 'IC21_DR_ts.txt');
	out22 = fullfile(SUBJDIR, 'IC22_DR_ts.txt');
	out23 = fullfile(SUBJDIR, 'IC23_DR_ts.txt');
	out24 = fullfile(SUBJDIR, 'IC24_DR_ts.txt');
	out25 = fullfile(SUBJDIR, 'IC25_DR_ts.txt');
	
	dlmwrite(out1, IC1, 'precision','%.6f');
	dlmwrite(out2, IC2, 'precision','%.6f');
	dlmwrite(out5, IC5, 'precision','%.6f');
	dlmwrite(out8, IC8, 'precision','%.6f');
	dlmwrite(out9, IC9, 'precision','%.6f');
	dlmwrite(out10, IC10, 'precision','%.6f');
	dlmwrite(out11, IC11, 'precision','%.6f');
	dlmwrite(out12, IC12, 'precision','%.6f');
	dlmwrite(out13, IC13, 'precision','%.6f');
	dlmwrite(out14, IC14, 'precision','%.6f');
	dlmwrite(out15, IC15, 'precision','%.6f');
	dlmwrite(out16, IC16, 'precision','%.6f');
	dlmwrite(out17, IC17, 'precision','%.6f');
	dlmwrite(out18, IC18, 'precision','%.6f');
	dlmwrite(out19, IC19, 'precision','%.6f');
	dlmwrite(out20, IC20, 'precision','%.6f');
	dlmwrite(out21, IC21, 'precision','%.6f');
	dlmwrite(out22, IC22, 'precision','%.6f');
	dlmwrite(out23, IC23, 'precision','%.6f');
	dlmwrite(out24, IC24, 'precision','%.6f');
	dlmwrite(out25, IC25, 'precision','%.6f');
	
	disp(['finished subject ' num2str(subject) ', run ' num2str(runnum)]);
end
