function compare_networks_run5_jake_dvs(~)
    maindir = pwd;
    my_Nics = 25;
    corr_mat = zeros(my_Nics,1); 
    mask = fullfile(maindir,'run5_FLIRT','gica_unconfounded_DR_25dim.ica','mask.nii.gz'); 
        for i1 = 1:my_Nics %rows
            ic1 = i1 - 1;    
            i1_str = sprintf('%04d',ic1); 
                split_melodic_IC_file1 = fullfile(maindir,'run5_FLIRT','gica_unconfounded_DR_25dim.ica',['IC_' i1_str '.nii.gz']);
                split_melodic_IC_file2 = fullfile(maindir,'run5_FLIRT','Level3_n44','Smooth_5mm','L3_mixed_C5_face-land.gfeat','cope1.feat','stats','zstat1_3mm.nii.gz'); %This is my face>land image
                %keyboard
                if exist(split_melodic_IC_file1,'file') && exist(split_melodic_IC_file2,'file')
                    sys_cmd = sprintf('sh compute_spatialcorr.sh %s %s %s',split_melodic_IC_file1, split_melodic_IC_file2, mask);
                    spatial_corr = system(sys_cmd);
                    spatial_corr_num = str2double(spatial_corr);
                    delete('demeaned*');
                    corr_mat(i1,1) = spatial_corr_num;
                    
                end
            fprintf('%3.3f%% of %s completed...\n',100*(i1/my_Nics),'DR');
        end
        figure,imagesc(corr_mat);
        title('DR')
        dlmwrite('face-land_corr_unconfounded_run5_DR.csv',corr_mat,'delimiter',',','precision','%.6f')
end

