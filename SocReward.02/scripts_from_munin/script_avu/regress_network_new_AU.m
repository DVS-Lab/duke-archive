try
    maindir = '/mnt/BIAC/munin4.dhe.duke.edu/Huettel/SocReward.02/Analysis/avu';    
    subject_list = load(fullfile(maindir, 'final_subs.txt'));    
    count = 0;
    for s = 1:length(subject_list)
        subject = subject_list(s);
        
        if subject == 13374 || subject == 13431 || subject == 14507
            runs = [1 2 3];
        elseif subject == 13647
            runs = [2 3 4];
        elseif subject == 13474
            runs = [1 3];
        elseif subject == 13944
            runs = [1 2];
        elseif subject == 14447
            runs = [1 4];
        else
            runs = [1 2 3 4];
        end
        
        for r = 1:length(runs)
            count = count + 1;
            
            designfile = fullfile(maindir, 'social_rewardphase', 'Social_nonSoc_anticip_FNIRT_lvl1_outcome_nextRTparamet', num2str(subject), ['run' num2str(runs(r)) ],  'social_nonsocial_outcome_nextRT.feat', 'design.mat');
            dof = load(fullfile(maindir, 'social_rewardphase', 'Social_nonSoc_anticip_FNIRT_lvl1_outcome_nextRTparamet', num2str(subject), ['run' num2str(runs(r)) ], 'social_nonsocial_outcome_nextRT.feat', 'stats', 'dof'));
            %designfile = fullfile(maindir, 'Social_nonSoc_anticip_FNIRT_lvl1', num2str(subject), ['run' num2str(runs(r)) ], 'FEAT', 'social_nonsocial_anticipation.feat', 'design.mat');
            %dof = load(fullfile(maindir, 'Social_nonSoc_anticip_FNIRT_lvl1', num2str(subject), ['run' num2str(runs(r)) ], 'FEAT', 'social_nonsocial_anticipation.feat', 'stats', 'dof'));
            numcolumns = 484 - dof;
            columnstrings = repmat('%s',1,numcolumns);
            mycommand = ['C = textscan(fid, ''' columnstrings ''' ,''CommentStyle'', ''/'');'];
            fid = fopen(designfile,'r');
            eval(mycommand);
            
            task = zeros(484,2);
            C_5 = str2double(C{1});
            C_6 = str2double(C{2});
            for i = 1:484
                task(i,1) = (C_5(i));
                task(i,2) = (C_6(i));
            end
            
            fname = sprintf('dr_stage1_subject%05d.txt',s-1); %dr_stage1_sorted_subject00000
            network_file = load(fullfile(maindir, 'SR_02_ICA_std', 'DR_output', fname));
            
            dmn = network_file(:,6);
            notdmn = network_file;
            notdmn(:,6) = [];
            %keyboard
            stats = regstats(zscore(dmn),zscore([task notdmn]), 'linear', 'all');
            tmp_dmn_beta(r,1) = stats.beta(2);
            tmp_dmn_beta(r,2) = stats.beta(3);
            
            ecn = network_file(:,4);
            notecn = network_file;
            notecn(:,4) = [];
            stats = regstats(zscore(ecn),zscore([task notecn]),'linear','all');
            tmp_ecn_beta(r,1) = stats.beta(2);
            tmp_ecn_beta(r,2) = stats.beta(3);
            
            lfpn = network_file(:,3);
            notlfpn = network_file;
            notlfpn(:,3) = [];
            stats = regstats(zscore(lfpn),zscore([task notlfpn]),'linear','all');
            tmp_lfpn_beta(r,1) = stats.beta(2);
            tmp_lfpn_beta(r,2) = stats.beta(3);
            
            rfpn = network_file(:,7);
            notrfpn = network_file;
            notrfpn(:,7) = [];
            stats = regstats(zscore(rfpn),zscore([task notrfpn]),'linear','all');
            tmp_rfpn_beta(r,1) = stats.beta(2);
            tmp_rfpn_beta(r,2) = stats.beta(3);
        end
        tmp_ecn_beta_faces(s,1) = mean(tmp_ecn_beta(:,1));
        tmp_ecn_beta_lands(s,1) = mean(tmp_ecn_beta(:,2));
        tmp_dmn_beta_faces(s,1) = mean(tmp_dmn_beta(:,1));
        tmp_dmn_beta_lands(s,1) = mean(tmp_dmn_beta(:,2));
        tmp_lfpn_beta_faces(s,1) = mean(tmp_lfpn_beta(:,1));
        tmp_lfpn_beta_lands(s,1) = mean(tmp_lfpn_beta(:,2));
        tmp_rfpn_beta_faces(s,1) = mean(tmp_rfpn_beta(:,1));
        tmp_rfpn_beta_lands(s,1) = mean(tmp_rfpn_beta(:,2));
        
        disp('subj run')
    end
    
    
    %figure,barweb_dvs([mean(tmp_ecn_beta_faces); mean(tmp_ecn_beta)]', [std(41)/sqrt(length(41)); std(41)/sqrt(length(41))]')
    %legend('DMN','ECN')
    
catch ME
    disp(ME.message)
    keyboard
end



