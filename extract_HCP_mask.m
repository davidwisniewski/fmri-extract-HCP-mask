%{ 
This script extracts a single ROI mask from the HCP mask file
Just look up the code for the ROI you are interested in in the mmp.csv
table, give the script the correct folder and run. 
%}

clear all
clc

%% FLAGS

% pick the ROI code you are interested in here
roicode = 1;
% where is the HCP mask file stored?
folder = 'ADD YOUR FOLDER HERE: C:\SOMEFOLDER';
% assuming you did not change the HCPO mmmaks filename, just leave this as
% it is
hcp_fname = 'HCP-MMP1_on_MNI152_ICBM2009a_nlin.nii,1';
% same applies here, don't change unless you changed the filename of the
% table file
table_fname = 'mmp.csv';

%% Extract the ROI label

% we automatically extract the ROI label from the table file
fid = fopen (sprintf('%s%s',folder, table_fname));
out = textscan(fid,'%s%s%s%s%s%s','Delimiter',',','Headerlines',1);
out_label = out{6}{roicode}(2:end-1); % this is the label we will use to name the output mask file
% clean up the label string: remove all spaces
out_label= out_label(find(~isspace(out_label)));
% remove dots . and plusses +, this will mess up saving the file
out_label = regexprep(out_label,'[.+]','');

%% Generate binary mask file

clear matlabbatch
matlabbatch{1}.spm.util.imcalc.input = {sprintf('%s%s',folder, hcp_fname)};
matlabbatch{1}.spm.util.imcalc.output = sprintf('%s.nii',out_label);
matlabbatch{1}.spm.util.imcalc.outdir = {folder};
matlabbatch{1}.spm.util.imcalc.expression = sprintf('(i1<%d)&(i1>%d)',roicode+.1,roicode-.1); % we just select the chosen ROI here 
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 0;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run',matlabbatch); 

