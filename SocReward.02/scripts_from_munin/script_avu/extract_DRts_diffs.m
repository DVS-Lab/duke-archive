
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
	DMN_ECN_ts = DMN_ts - ECN_ts;
	ECN_DMN_ts = ECN_ts - DMN_ts;
	
	DMN_minus_ECN_out = fullfile(SUBJDIR, 'DMN_ECN_ts.txt');
	ECN_minus_DMN_out = fullfile(SUBJDIR, 'ECN_DMN_ts.txt');
	
	dlmwrite(DMN_minus_ECN_out, DMN_ECN_ts, 'precision', '%.6f');
	dlmwrite(ECN_minus_DMN_out, ECN_DMN_ts, 'precision', '%.6f');
	
	disp(['finished subject ' num2str(subject) ', run ' num2str(runnum)]);
end
