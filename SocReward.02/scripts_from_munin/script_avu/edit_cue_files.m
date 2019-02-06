
maindir = '/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis/';

sublist = load(fullfile(maindir, 'avu', 'final_sub_runs.txt'));
subs = sublist(:,1);
runs = sublist(:,2);


for i=1:length(sublist);
	subject = subs(i);
	runnum = runs(i);
	
	sub_orig_cue_dir = fullfile(maindir, 'FSL', num2str(subject), 'anticipation_model_FNIRT', 'Smooth_5mm', ['run' num2str(runnum) '.feat'], 'custom_timing_files');

	orig_cue_file = load(fullfile(sub_orig_cue_dir, 'ev5.txt'));
	new_cue_file = orig_cue_file;
	new_cue_file(:,2) = 0;
	
	outputdir = fullfile(maindir, 'FSL', 'EV_files', 'Anticipation_Models', num2str(subject), ['run' num2str(runnum)]);
	
	new_cue_output = fullfile(outputdir,'cues_impulse_au.txt');

	dlmwrite(new_cue_output, new_cue_file, 'delimiter', '\t');
	
	if exist(new_cue_output)
		disp(['finished subject ' num2str(subject) ', run ' num2str(runnum)]);
	end
end
