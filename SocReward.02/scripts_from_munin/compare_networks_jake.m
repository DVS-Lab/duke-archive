function compare_networks_jake(~)

try
    maindir = pwd;
    my_Nics = 25;
    corr_mat = zeros(my_Nics); 
    mask = fullfile(maindir,'gica_DR_25dim.ica','mask.nii.gz'); 
        for i1 = 1:my_Nics %rows
            ic1 = i1 - 1;    
            i1_str = sprintf('%04d',ic1); 
                split_melodic_IC_file1 = fullfile(maindir,'gica_DR_25dim.ica',['IC_' i1_str '.nii.gz']);
                split_melodic_IC_file2 = fullfile(maindir,'Level3_n49','new_RMI','anticipation_model_face-land_FNIRT','Smooth_5mm','L3_mixed_C10_face-land_wAQ_preference.gfeat','cope1.feat','stats','zstat1_3mm.nii.gz'); %This is my face>land image
                if exist(split_melodic_IC_file1,'file')
                    status = 1;
                    while status
                        sys_cmd = sprintf('sh compute_spatialcorr.sh %s %s %s',split_melodic_IC_file1, split_melodic_IC_file2, mask);
                        [status,spatial_corr] = system(sys_cmd);
                        if status
                            fprintf('something got fucked up looking at RSN %s on IC %s\nrecalculating...\n',i1_str);
                        end
                        spatial_corr_num = str2double(spatial_corr);
                        if isnan(spatial_corr_num)
                            disp('ugh, still failed because of nans\nrevalculating..\n')
                            status = 1;
                        end
                    end
                    delete('demeaned*');
                    corr_mat(i1,i2) = spatial_corr_num;
                else
                    fprintf('missing: %s\n',split_melodic_IC_file1);
                    corr_mat(i1,i2) = 0;
                end
            fprintf('%3.3f%% of %s completed...\n',100*(i1/my_Nics),'DR');
        end
        figure,imagesc(corr_mat);
        title('DR')
        dlmwrite([ 'face-land_corr_DR.csv'],corr_mat,'delimiter',',','precision','%.6f')
catch ME
    disp(ME.message)
    keyboard
end

