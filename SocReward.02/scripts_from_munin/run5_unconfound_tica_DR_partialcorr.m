maindir = '/mnt/BIAC/.users/dvs3/munin3.dhe.duke.edu/Huettel/SocReward.02/Analysis/FSL/run5_FLIRT/gica_unconfounded_tensor_DR_25dim.ica/DR_output_Young';


datadir = '/mnt/BIAC/.users/dvs3/munin3.dhe.duke.edu/Huettel/SocReward.02/Analysis/FSL/run5_FLIRT/gica_unconfounded_tensor_DR_25dim.ica/DR_output_Young'; 

%useable runs for useable subject

BIAC_sub_list = [13282 13298 13323 13329 13383 13392 13483 13527 13534 13540 ...
    13551 13559 13637 13647 13654 13696 13849 13863 13875 13886 13928 13944 13952 14064 14265 14447 ...
    14470 14478 14507 14518 14588 14694 14715 14779 14841 14934 14955 15014 15092 15115 15491 15596 15606 15690];
N=-1;

for s = 1:length(BIAC_sub_list)
    BIAC_sub_num = BIAC_sub_list(s);
        outdir = fullfile(maindir,'Partial_Corr_tica',num2str(BIAC_sub_num));

        mkdir(outdir)

        
        N=N+1;
        zeropaddedN = sprintf('%05d',N);
        
        %load dr_stage1 file
        
        fname = fullfile(maindir,['dr_stage1_subject' num2str(zeropaddedN) '.txt']);
        data = load(fname);
        

        N_1 = data(:,1);
        N_2 = data(:,2);
        N_3 = data(:,3);
        N_4 = data(:,4);
        N_5 = data(:,5);
        N_6 = data(:,6);
        N_7 = data(:,7);
        N_8 = data(:,8);
        N_9 = data(:,9);
        N_10 = data(:,10);
        N_11 = data(:,11);
        N_12 = data(:,12);
        N_13 = data(:,13);
        N_14 = data(:,14);
        N_15 = data(:,15);
        N_16 = data(:,16);
        N_17 = data(:,17);
        N_18 = data(:,18);
        N_19 = data(:,19);
        N_20 = data(:,20);    
        N_21 = data(:,21);
        N_22 = data(:,22);
        N_23 = data(:,23);
        N_24 = data(:,24);
        N_25 = data(:,25);        
        
       x = partialcorr([N_1 N_2 N_3 N_4 N_5 N_6 N_7 N_8 N_9 N_10 ...
            N_11 N_12 N_13 N_14 N_15 N_16 N_17 N_18 N_19 N_20 ...
            N_21 N_22 N_23 N_24 N_25]);
        
        %write out partial corr images
        
        fid = fopen(fullfile(outdir,'partial_corr.txt'),'w');
        fprintf(fid,'%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \n', x(:,1), x(:,2), x(:,3), x(:,4), x(:,5), x(:,6), x(:,7), x(:,8), x(:,9), x(:,10), x(:,11), x(:,12), x(:,13), x(:,14), x(:,15), x(:,16), x(:,17), x(:,18), x(:,19), x(:,20), x(:,21), x(:,22), x(:,23), x(:,24), x(:,25));
        fclose(fid);
end



