function visualize_data(subjnum,startrun,endrun)
% This function loads the data for all runs for a given Subject. It will cycle
% through each run using readmr and showsrs2. It pauses and closes the
% windows after each run. To proceed to the next run/task, you can press any
% key. It will also display the BETed and non-BETed anatomicals (it does
% this first). Importantly, it will delete the  first 8 volumes of the
% functional data before displaying it -- and it will display the
% difference image for the functionals.
%
% You have to have the BIAC tools in your path for this function to work.
% e.g. for when on the BIAC computer, \\munin\Programs\MATLAB\BIAC
% javaaddpath \\munin\Programs\MATLAB\BIAC\java
% addpath \\munin\Programs\MATLAB\BIAC\general
% addpath \\munin\Programs\MATLAB\BIAC\mr
% addpath \\munin\Programs\MATLAB\BIAC\fix
%
% USAGE: visualize_data(subjnum,startrun,endrun)
% subjnum is the subject number (without the date), and it's entered as
% number. startrun/endrun represent the starting and ending runs
%
% Optionally, you can enter a task_list if you want to skip the anatomicals
% and just work on a specific task or tasks. The task list should be
% entered as a cell array.
% EX: visualize_data(12345,1,5)
%
% Written by David V. Smith (david.v.smith@duke.edu)
% created: March 17, 2010
% Edit: March 20, 2010 (DVS: changed disdaqs to 8 to match paradigms)
% Edit: March 24, 2010 (DVS: added difference images for functionals)
% Edit: March 25, 2010 (DVS: altered structure to avoid memory issues)
% Edit: March 29, 2010 (DVS: made task_list optional so you can skip tasks)
% Edit: July 20, 2011 (DVS: modified for SocReward.02)

maindir = pwd;
pack;

fprintf('Loading anatomical data for %d...\n', subjnum)
anatfile = readmr(fullfile(maindir,num2str(subjnum),[num2str(subjnum) '_anat.nii.gz']));
anatfile_bet = readmr(fullfile(maindir,num2str(subjnum),[num2str(subjnum) '_anat_brain.nii.gz']));
showsrs2(anatfile)
showsrs2(anatfile_bet)
fprintf('Close anatomicals and continue to functional data?\n\n')
abort = wait_for_response;
close all;
clear anatfile_bet anatfile
if abort
    return
end


for r = startrun:endrun
    fprintf('Loading functional data for run %d...\n\n', r)
    
    
    funcfile = fullfile(maindir,num2str(subjnum),['run' num2str(r) '.nii.gz']);
    pack;
    if exist(funcfile,'file')
        funcdata = readmr(funcfile);
        funcdata.data = funcdata.data(:,:,:,9:end);
        oldt = funcdata.info.dimensions(4).size;
        funcdata.info.dimensions(4).size = oldt - 8;
        showsrs2(funcdata)
        
        fprintf('Displaying run %d of...\n', r)
        fprintf('Clear raw functional and show difference image?\n')
        abort = wait_for_response;
        close all;
        if abort
            return
        end
        
        diffdata = funcdata;
        clear funcdata
        diffdata.data = diff(diffdata.data, 1, 4);
        showsrs2(diffdata)
        fprintf('Continue to the next run and close showsrs2 windows?\n')
        abort = wait_for_response;
        clear diffdata
        close all;
        
        if abort
            return
        end
    else
        fprintf('Cannot find func file for run %d!!!\n', r)
        fprintf('Continue to the next run?\n')
        abort = wait_for_response;
        close all;
        clear funcdata diffdata
        pack;
        if abort
            return
        end
    end
end



%related functions
function abort = wait_for_response() %added this because 'pause' wouldn't work when navigating showsrs2 with q w e a s d keys
keep_waiting = 1;
while keep_waiting
    yes_no = input('yes/no: ', 's');
    if strcmp(yes_no, 'yes')
        keep_waiting = 0;
        abort = 0;
    elseif strcmp(yes_no, 'no')
        abort = 1;
        return;
    else
        fprintf('Please respond with either ''yes'' or ''no''.\n')
    end
end




