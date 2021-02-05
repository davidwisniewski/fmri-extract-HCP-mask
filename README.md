# fmri-extract-HCP-mask
This script lets you easily extract a specific binary mask file from the HCP-MMP1.0 parcellation atlas. 

## Set up
1) Download all files.
2) Unzip HCP_atlas.zip.
3) Check that both the atlas files (.nii) and the mmp.csv file are in the same folder. 

## How to use
This is a simple script that takes the volumetric map of the Human Connectome Project MMP1.0 parcellation (included here), extracts a desired ROI, and saves it as a binary mask file. The volumetric map is in MNI space, and so will the resulting mask files. 
1) Go to the ROI lookup table (mmp.csv). Find the ROI you are interested in, and write down the ROI code (num.roi column). You can run multiple ROIs or just one. 
2) call the create_HCP_mask() function. 

## Function input
- the roicode/s you looked up
- the folder where you put the atlas files
- an output folder
- operation: If you picked multiple rois you can either save all separately ('single'), or combine them into a single large ROI ('sum'). 
- laterality: You can select whether you want to extract left ('l'), right ('r'), or bilateral ('b') ROIs. 

## Sources
The files used here are not mine, all credits to the creators:
- volumetric HCP-MMN1.0 map: https://figshare.com/articles/dataset/HCP-MMP1_0_projected_on_MNI2009a_GM_volumetric_in_NIfTI_format/3501911
- ROI lookup table: https://github.com/mcfreund/stroop-rsa/blob/master/out/atlases/mmp.csv

## Requirements
- downloaded all files and unzip the HCP-MMP1_on_MNI152_ICBM2009a_nlin.zip file
- Matlab + SPM12 installed

## Bugs / Improvements
If you find bugs in this script or have suggestions for improvement, please report both here https://github.com/davidwisniewski/fmri-extract-HCP-mask/issues

## Contact
david.wisniewski@ugent.be

