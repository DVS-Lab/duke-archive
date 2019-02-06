function get_QA_summary()
% clear all
% warning off all
% if isunix
%     maindir = '/Volumes/Huettel/Imagene.02/Analysis/TaskData';
% else
%     maindir = 'M:\Imagene.02\Analysis\TaskData';
% end

maindir = pwd;

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
%11196, 11209, 11210, 11212 -- fat sat and data ambiguities. excluded. ---
%ADDED BACK, SO BEWARE.
sub_list = [10156 10168 10181 10199 10255 10256 10264 10265 10279 10280 10281 ...
    10286 10287 10294 10304 10305 10306 10314 10315 10335 10350 10351 10352 ...
    10358 10359 10360 10387 10414 10415 10416 10424 10425 10426 10471 10472 ...
    10474 10481 10482 10483 10512 10515 10521 10523 10524 10525 10558 10560 ...
    10565 10583 10602 10605 10615 10657 10659 10665 10670 10696 10697 10698 ...
    10699 10705 10706 10707 10746 10747 10749 10757 10762 10782 10783 10785 ...
    10793 10794 10795 10817 10827 10844 10845 10858 10890 11021 11022 11024 ...
    11029 11058 11059 11065 11066 11067 11171 11176 11215 11216 11217 11232 ...
    11233 11235 11243 11244 11245 11264 11266 11272 11273 11274 11291 11292 ...
    11293 11326 11327 11328 11335 11363 11364 11366 11371 11372 11373 11383 ...
    11393 11394 11402 11430 11473 11479 11511 11525 11545 11578 11584 11602 ...
    11605 11625 11659 11660 11692 11738 11762 11778 11805 11865 11878 11941 ...
    11950 12015 12071 12082 12089 12097 12132 12159 12165 12175 12176 ...   %took out 12193. see note below.
    12217 12235 12277 12280 12294 12314 12360 12372 12380 12383 12393 12400 ...
    12411 12412 12444 12459 12460 12476 12496 12541 12550 12551 12564 12580 ...
    12596 12606 12614 12629 12664 12665 12677 12678 12679 12691 12711 12717 ...
    12731 12742 12755 12756 12757 12758 12766 12768 12780 12789 12791 12802 ...
    12815 12816 12817 12828 12839 12840 12850 12873 12874 12875 12879 12880 ...
    11196 11209 11210 11212 12893 12894 12896 12905 12907 12911 12923 12960 ...
    12961 12988 12989 13011 13051 13060];

%John- the scanner crashed due to a campus power outage during MID3 of subject 12193. 
%The subject came back at a later date as subject 12294 and the full study was completed.
%DVS: taking out 12193

sub_list = sort(sub_list);


tasks = {'Framing','MID','Risk','Resting'};


fid = fopen(['QA_summary_' date '.txt'],'w');
fprintf(fid,'Subject \tTask \tRun \tMotion: abs mean \tMotion: rel mean \tWB SFNR \tBIAC SFNR \tN bad volumes \tpct bad volumes \ttotal volumes \n'); %9
%fprintf(fid,'%s \t%s \t%d \t%.3f \t%.3f \t%.3f \t%.3f \t%d \n', subject, task, r, peak_max_abs_motion_run, peak_max_rel_motion_run, wb_sfnr_run, BIAC_QA, n_badtimepoints);

fid2 = fopen(['subject_mean_QA_summary_' date '.txt'],'w');
fprintf(fid2,'Subject \tMotion: abs mean \tMotion: rel mean \tWB SFNR \tBIAC SFNR \tN bad volumes \tpct bad volumes \n'); %7

fid3 = fopen(['subject_median_QA_summary_' date '.txt'],'w');
fprintf(fid3,'Subject \tMotion: abs mean \tMotion: rel mean \tWB SFNR \tBIAC SFNR \tN bad volumes \tpct bad volumes \n'); %7


for s = 1:length(sub_list)
    subject = num2str(sub_list(s));
    sub_num = sub_list(s);
    r_counter = 0;
    
    for t = 1:length(tasks)
        task = tasks{t};
        for r = 1:3
            
            skip = is_missingdata(subject,r,task);
            if skip
                continue
            end
            
            r_counter = r_counter + 1;
            
            wb_file = fullfile(maindir,subject,task,'MELODIC_FLIRT','Smooth_6mm',['run' num2str(r) '.ica'],'wb_raw.txt');
            abs_motion_file = fullfile(maindir,subject,task,'MELODIC_FLIRT','Smooth_6mm',['run' num2str(r) '.ica'],'mc','prefiltered_func_data_mcf_abs.rms');
            rel_motion_file = fullfile(maindir,subject,task,'MELODIC_FLIRT','Smooth_6mm',['run' num2str(r) '.ica'],'mc','prefiltered_func_data_mcf_rel.rms');
            
            if exist(wb_file,'file')
                wb = load(wb_file);
                wb_sfnr_run = mean(wb)/std(wb);
                wb_sfnr(r_counter) = wb_sfnr_run;
            else
                fprintf('DOES NOT EXIST: %s\n', wb_file);
                wb_sfnr_run = 0;
                wb_sfnr(r_counter) = 0;
            end
            
            %these are changed. 
            %initially took diffs, then took median, now taking mean.
            if exist(abs_motion_file,'file')
                abs_motion = load(abs_motion_file); %motion relative to the middle time point
                %peak_max_abs_motion_run = max(abs_motion) - min(abs_motion);
                peak_max_abs_motion_run = mean(abs_motion);
                
                rel_motion = load(rel_motion_file); %motion relative to the preceding time point
                %peak_max_rel_motion_run = max(rel_motion) - min(rel_motion);
                peak_max_rel_motion_run = mean(rel_motion);
            else
                fprintf('ERROR: motion correction files are missing for run %d of subject %s on %s\n', r, subject, task);
                peak_max_abs_motion_run = 0;
                peak_max_rel_motion_run = 0;
            end
            so_file = fullfile(maindir,subject,task,['so_run' num2str(r) '.txt']);
            if exist(so_file,'file')
                load(so_file)
                eval(['so = so_run' num2str(r) ';' ]);
                if so(1) ~= 1
                    fprintf('WARNING: slice order is flipped for run %d of subject %s on %s\n', r, subject, task);
                end
            else
                fprintf('ERROR: slice order file is missing for run %d of subject %s on %s\n', r, subject, task);
            end
            
            bad_TRs_file = fullfile(maindir,subject,task,'MELODIC_FLIRT','Smooth_6mm',['run' num2str(r) '.ica'],'bad_timepoints.txt');
            if exist(bad_TRs_file,'file')
                load(bad_TRs_file);
                [rr n_badtimepoints] = size(bad_timepoints);
                pct_bad = n_badtimepoints / rr;
            else
                n_badtimepoints = 0;
                pct_bad = 0;
            end
            
            BIAC_QA_file = fullfile(maindir,subject,task,['QA_' task],['SFNR_run' num2str(r) '.txt']);
            if strcmp(subject,'11245') && strcmp(subject,'11245') && r == 3
                BIAC_QA_file = fullfile(maindir,subject,task,['QA_' task],['SFNR_run1.txt']);
            end
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
            
            
            fprintf(fid,'%s \t%s \t%d \t%.3f \t%.3f \t%.3f \t%.3f \t%d \t%.3f \t%d \n', subject, task, r, peak_max_abs_motion_run, peak_max_rel_motion_run, wb_sfnr_run, BIAC_QA, n_badtimepoints, pct_bad, rr);
            fprintf('%s \t%s \t%d \t%.3f \t%.3f \t%.3f \t%.3f \t%d \t%.3f \t%d \n', subject, task, r, peak_max_abs_motion_run, peak_max_rel_motion_run, wb_sfnr_run, BIAC_QA, n_badtimepoints, pct_bad, rr);
            
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
    end
    
    fprintf(fid2,'%s \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f \n', subject, mean(all_peak_max_abs_motion), mean(all_peak_max_rel_motion), mean(all_wb_sfnr), nanmean(all_BIAC_QA), mean(all_n_badtimepoints), mean(all_pct_bad));
    fprintf(fid3,'%s \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f \n', subject, median(all_peak_max_abs_motion), median(all_peak_max_rel_motion), median(all_wb_sfnr), nanmedian(all_BIAC_QA), median(all_n_badtimepoints), median(all_pct_bad));

    
    clear sum_max_motion* peak_max_motion* motion_std_composite* air_sfnr* wb_sfnr* brain_air_c* rel* abs* all*
end
fclose(fid);
fclose(fid2);
fclose(fid3);
