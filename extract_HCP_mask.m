%{
This function extracts single/multiple ROI masks from the HCP mask file
Just look up the code for the ROI you are interested in in the mmp.csv
table, call the function with the correct folder and run. 

Operation:
-'single' = extract one ROI per each roi code
-'sum' = combined all roi codes into one big roi

Laterality:
Choose whether you want left, right, or bilateral ROIs to be extracted
-'l' = left
-'r' = right
-'b' = bilateral

Dilation:
Select how much the resulting mask should be dilated. For instance, if you
set this to 2, the mask will be expanded by 2 voxels in all 3 dimensions. 
No dilation = 0 (default setting). 

Example calls:
1) extract single ROI (roi number 2) into default path
extract_HCP_mask(2, 'C:\root\fmri-extract-HCP-mask\', 'D:\root\fmri-extract-HCP-mask\','single','b')
2) extract multiple ROIs (roi numbers 2, 4, 8) into new folder (don't
forget the '\' at the end of the path!
extract_HCP_mask([2 4 8], 'C:\root\fmri-extract-HCP-mask\', 'D:\root\fmri-extract-HCP-mask\NEWFOLDER\','single','b')
3) combine multiples ROIs (roi numbers 2, 4, 8) into one single ROI, and
save it in a new folder (don't forget the '\' at the end!)
extract_HCP_mask([4 21 45], 'D:\GitHub\fmri-extract-HCP-mask\', 'D:\GitHub\fmri-extract-HCP-mask\NEWFOLDER\','sum','b')

---
David Wisniewski (david.wisniewski@ugent.be)
Carlos González-García (carlos.gonzalezgarcia@ugent.be)
%}

function extract_HCP_mask(roicodes, HCP_path, output_path, operation, laterality, dilation)

%% PREPARATION
    % create output folder if it does not exist
    if ~exist(output_path)
        mkdir(output_path)
    end

    % assuming you did not change any filenammes, just leave this as
    % this just points to the lookup table
    table_fname = 'mmp.csv';

    for r = 1:length(roicodes)
        %% Extract the ROI label
        % we automatically extract the ROI label from the table file
        fid = fopen (sprintf('%s%s',HCP_path, table_fname));
        out = textscan(fid,'%s%s%s%s%s%s','Delimiter',',','Headerlines',1);
        out_label = out{2}{roicodes(r)}; % this is the label we will use to name the output mask file
        % clean up the label string: remove all spaces
        out_label= out_label(find(~isspace(out_label)));
        % remove dots . and plusses +, this will mess up saving the file
        out_label = regexprep(out_label,'[.+]','');

        %% Generate a single binary mask file per selected ROI
        clear matlabbatch
        % select either bilateral, left or right roi
        if laterality=='b'
            matlabbatch{1}.spm.util.imcalc.input = {sprintf('%s%s',HCP_path, 'HCP-MMP1_on_MNI152_ICBM2009a_nlin.nii,1')};
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_bilateral.nii',out_label);
        elseif laterality=='l'
            matlabbatch{1}.spm.util.imcalc.input = {sprintf('%s%s',HCP_path, 'HCP-MMP1_on_MNI152_ICBM2009a_nlin_left.nii,1')};
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_left.nii',out_label);
        elseif laterality=='r'
            matlabbatch{1}.spm.util.imcalc.input = {sprintf('%s%s',HCP_path, 'HCP-MMP1_on_MNI152_ICBM2009a_nlin_right.nii,1')};
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_right.nii',out_label);
        end
        matlabbatch{1}.spm.util.imcalc.outdir = {output_path};
        matlabbatch{1}.spm.util.imcalc.expression = sprintf('(i1<%g)&(i1>%g)',roicodes(r)+.1,roicodes(r)-.1); % we just select the chosen ROI here 
        matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        spm_jobman('run',matlabbatch); 
        % dilate resulting image
        if exist('dilation') % was the argument handed to the function?
            if dilation % is dilation > 0?
                % read the resulting image 
                result_header = spm_vol(sprintf('%s%s',output_path,matlabbatch{1}.spm.util.imcalc.output));
                result_volume = spm_read_vols(result_header);
                % dilate the mask
                dilated_volume = dilate_volume(result_volume, dilation);
                % overwrite the undilated mask
                spm_write_vol(result_header,dilated_volume);         
            end
        end
               
        if strcmp(operation,'single')
            fprintf(['------ ' matlabbatch{1}.spm.util.imcalc.output ' written to folder ------\n'])
        else
            sum_inputs(r) = {sprintf('%s%s',output_path, matlabbatch{1}.spm.util.imcalc.output)};
        end
        
    end
    %% Generate a summary mask file from all selected ROIs 
    % create summary image, with all selected ROIs pooled into one
    if strcmp(operation,'sum') && length(roicodes) > 1
        % first create a label for the sum image, by concatenating all
        % individual labels
        out_label_sum=[];
        for r = 1:length(roicodes)
            out_label = out{2}{roicodes(r)};%(2:end-1); % this is the label we will use to name the output mask file
            % clean up the label string: remove all spaces
            out_label= out_label(find(~isspace(out_label)));
            % remove dots . and plusses +, this will mess up saving the file
            out_label = regexprep(out_label,'[.+]','');
            out_label_sum = [out_label_sum out_label]
        end
        clear matlabbatch
        matlabbatch{1}.spm.util.imcalc.input = sum_inputs';
        if laterality=='b'
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_sum_bilateral.nii',out_label_sum);
        elseif laterality=='l'
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_sum_left.nii',out_label_sum);
        elseif laterality=='r'
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_sum_right.nii',out_label);
        end
        matlabbatch{1}.spm.util.imcalc.outdir = {output_path};
        matlabbatch{1}.spm.util.imcalc.expression = 'sum(X)'; % we just select the chosen ROI here
        matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        spm_jobman('run',matlabbatch);
        % dilate resulting image
        if exist('dilation')
            if dilation
                result_header = spm_vol(sprintf('%s%s',output_path,matlabbatch{1}.spm.util.imcalc.output));
                result_volume = spm_read_vols(result_header);
                dilated_volume = dilate_volume(result_volume, dilation);
                spm_write_vol(result_header,dilated_volume);         
            end
        end
    end
end

