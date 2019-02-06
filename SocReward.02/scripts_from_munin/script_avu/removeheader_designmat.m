maindir = '/mnt/BIAC/munin4.dhe.duke.edu/Huettel/SocReward.02/Analysis/avu';

sublist = load(fullfile(maindir, 'scripts', 'SR02_subsRuns.txt'));
subs = sublist(:,1);
runs = sublist(:,2);

for i = 1:length(sublist)
    inputdesign = fullfile(maindir, 'social_rewardphase', 'SR02_social_gPPI_DMN_ECN_allDRICs_newzeros', ['PPI_' num2str(subs(i)) '_run' num2str(runs(i)) '.feat'], 'design.mat');
    outputdesign = fullfile(maindir, 'social_rewardphase', 'SR02_social_gPPI_DMN_ECN_allDRICs_newzeros', ['PPI_' num2str(subs(i)) '_run' num2str(runs(i)) '.feat'], 'design_noheader.txt');
    
    sys_cmd = sprintf(['grep -v [A-Za-df-z] ' inputdesign ' | grep [0-9] > ' outputdesign]);
    system(sys_cmd);
    
    display(['subject: ' num2str(subs(i)) ', run num: ' num2str(runs(i))])
    
    clear inputdesign outputdesign sys_cmd
end
