function get_QA_summary_SocReward_Run5_jsy()

if isunix
    maindir = '/Volumes/Huettel/SocReward.02/Analysis/FSL/';
else
    maindir = 'M:\SocReward.02\Analysis\FSL';
end



% notes about motion:
% abs motion = motion relative to the middle volume
% rel motion = motion relative to the preceding time point
%
% Devlin post (<2mm is bad): https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind02&L=FSL&D=0&P=252084
% Smith post (rel vs abs): https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind02&L=FSL&D=0&P=251459



cd(maindir)
% sub_list = dir('1*');
% sub_list = struct2cell(sub_list);
% sub_list = sub_list(1,1:end);

%11431 and 10169 -- removed from list (got out of scanner; using first subject number only)
%11196, 11209, 11210, 11212 -- fat sat and data ambiguities. excluded.
sub_list = [13282 13298 13323 13329 13346 13367 13374 13383 13392 ...
    13431 13474 13483 13527 13534 13540 13551 13559 13637 13647 ...
    13654 13696 13849 13863 13875 13886 13928 13944 13952 ...
    14064 14265 14447 14470 14478 14507 14518 14588 14694 14715 ...
    14779 14841 14934 14955 15014 15092 15102 15115 15491 15596 15606 15690];







fid = fopen(['QA_summary_' date '.txt'],'w');
fprintf(fid,'Subject \tTask \tRun \tMotion: abs mean \tMotion: rel mean \tWB SFNR \tBIAC SFNR \tN bad volumes \tpct bad volumes \n'); %9
%fprintf(fid,'%s \t%s \t%d \t%.3f \t%.3f \t%.3f \t%.3f \t%d \n', subject, task, r, peak_max_abs_motion_run, peak_max_rel_motion_run, wb_sfnr_run, BIAC_QA, n_badtimepoints);

fid2 = fopen(['subject_avg_QA_summary_' date '.txt'],'w');
fprintf(fid2,'Subject \tMotion: abs mean \tMotion: rel mean \tWB SFNR \tBIAC SFNR \tN bad volumes \tpct bad volumes \n'); %7

for s = 1:length(sub_list)
    subject = num2str(sub_list(s));
    sub_num = sub_list(s);
    r_counter = 0;
    

        for r = 5
            
            if r == 5 && s == 7
                skip = 1;
            end
            
            if r == 5 && s == 11
                skip = 1;
            end
            
            if r == 5 && s == 49
                skip = 1;
            end
            
            task='normal';
                        
            r_counter = r_counter + 1;
            
            wb_file = fullfile(maindir,subject,'MELODIC_FLIRT','Smooth_5mm',['run' num2str(r) '.ica'],'wb_raw.txt');
            abs_motion_file = fullfile(maindir,subject,'MELODIC_FLIRT','Smooth_5mm',['run' num2str(r) '.ica'],'mc','prefiltered_func_data_mcf_abs.rms');
            rel_motion_file = fullfile(maindir,subject,'MELODIC_FLIRT','Smooth_5mm',['run' num2str(r) '.ica'],'mc','prefiltered_func_data_mcf_rel.rms');
            
            if exist(wb_file,'file')
                wb = load(wb_file);
                wb_sfnr_run = mean(wb)/std(wb);
                wb_sfnr(r_counter) = wb_sfnr_run;
            else
                fprintf('DOES NOT EXIST: %s\n', wb_file);
                wb_sfnr_run = 0;
                wb_sfnr(r_counter) = 0;
            end
            
            %these are changed. now taking diffs
            if exist(abs_motion_file,'file')
                abs_motion = load(abs_motion_file); %motion relative to the middle time point
                peak_max_abs_motion_run = mean(abs_motion);
                rel_motion = load(rel_motion_file); %motion relative to the preceding time point
                peak_max_rel_motion_run = mean(rel_motion);
            else
                fprintf('ERROR: motion correction files are missing for run %d of subject %s on %s\n', r, subject, task);
                peak_max_abs_motion_run = 0;
                peak_max_rel_motion_run = 0;
            end
            so_file = fullfile(maindir,subject,['so_run' num2str(r) '.txt']);
            if exist(so_file,'file')
                load(so_file)
                eval(['so = so_run' num2str(r) ';' ]);
                if so(1) ~= 1
                    fprintf('WARNING: slice order is flipped for run %d of subject %s on %s\n', r, subject, task);
                end
            else
                fprintf('ERROR: slice order file is missing for run %d of subject %s on %s\n', r, subject, task);
            end
            
            bad_TRs_file = fullfile(maindir,subject,'MELODIC_FLIRT','Smooth_5mm',['run' num2str(r) '.ica'],'bad_timepoints.txt');
            if exist(bad_TRs_file,'file')
                load(bad_TRs_file);
                [rr n_badtimepoints] = size(bad_timepoints);
                pct_bad = n_badtimepoints / rr;
            else
                n_badtimepoints = 0;
                pct_bad = 0;
            end
            
            
            BIAC_QA_file = fullfile(maindir,subject,'QA',['SFNR_run' num2str(r) '.txt']);
            if exist(BIAC_QA_file,'file')
                try
                    BIAC_QA = load(BIAC_QA_file);
                catch
                    fprintf('CANNOT LOAD BIAC QA FILE: %s\nMake sure data exists!', BIAC_QA_file);
                end
            else
                fprintf('DOES NOT EXIST: %s\n', BIAC_QA_file);
                BIAC_QA = 0;
            end
            
            fprintf(fid,'%s \t%s \t%d \t%.3f \t%.3f \t%.3f \t%.3f \t%d \t%.3f \n', subject, task, r, peak_max_abs_motion_run, peak_max_rel_motion_run, wb_sfnr_run, BIAC_QA, n_badtimepoints, pct_bad);
            fprintf('%s \t%s \t%d \t%.3f \t%.3f \t%.3f \t%.3f \t%d \t%.3f \n', subject, task, r, peak_max_abs_motion_run, peak_max_rel_motion_run, wb_sfnr_run, BIAC_QA, n_badtimepoints, pct_bad);
            
            if isempty(BIAC_QA)
                BIAC_QA = NaN;
            end
            all_peak_max_abs_motion(r_counter) = peak_max_abs_motion_run;
            all_peak_max_rel_motion(r_counter) = peak_max_rel_motion_run;
            all_wb_sfnr(r_counter) = wb_sfnr_run;
            all_BIAC_QA(r_counter) = BIAC_QA;
            all_n_badtimepoints(r_counter) = n_badtimepoints;
            all_pct_bad(r_counter) = pct_bad;
            
            
        end
    
    fprintf(fid2,'%s \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f \n', subject, mean(all_peak_max_abs_motion), mean(all_peak_max_rel_motion), mean(all_wb_sfnr), nanmean(all_BIAC_QA), mean(all_n_badtimepoints), mean(all_pct_bad));

    
    clear sum_max_motion* peak_max_motion* motion_std_composite* air_sfnr* wb_sfnr* brain_air_c* rel* abs* all*
end
fclose(fid);





% function skip = is_missingdata(subjnum,runnum)
% % This function lists exceptions and missing data so that those can be
% % skipped in all matlab functions related to SocReward.02. 
% % function skip = is_missingdata(subjnum,runnum,task)
% %
% % Written by David V. Smith (david.v.smith@duke.edu)
% % Last edit: 5/15/10
% 
% 
% skip = 0;
% subjnum = str2double(subjnum);
% 
% %resting only has 1 run
% if runnum == 4 && subjnum == 13374
% 	skip = 1;
% end
% 
% if runnum == 4 && subjnum == 13474
% 	skip = 1;
% end



