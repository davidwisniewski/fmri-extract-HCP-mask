% Dilate a mask file 
%{
Takes any 3d volume in matrix form, and dilates any nonzero voxels by a
given factor. Dilation is expressed in voxels. 

---
David Wisniewski (david.wisniewski@ugent.be)
%}

function dilated_volume=dilate_volume(volume,dilation)

    %s = max(dilation, 0);
	
    % get the image dimensions first
	[x,y,z] = size(volume);
    
    % create an empty output image 
	dilated_volume = zeros (x,y,z);
    
    % find the nonzero voxels in the input mask file
    [xind,yind,zind] = ind2sub( [x,y,z],find(volume));

    % loop over all nonzero voxels 
	for i = 1:length(xind)
		% get coordinates of selected voxel
        xind_current = xind(i);	
        yind_current = yind(i);	
        zind_current = zind(i);
        % now select which voxels should be included in the dilated image
        % dilation along x dimension
        xmin = max(1,xind_current-dilation); 	
        xmax = min(xind_current+dilation,x);
	    % dilation along y dimension
        ymin = max(1,yind_current-dilation);	
        ymax = min(yind_current+dilation,y);
		% dilation along z dimension
        zmin = max(1,zind_current-dilation);	
        zmax = min(zind_current+dilation,z);
        % for all selected voxels, set them to 1 / include them in the mask        
		dilated_volume(xmin:xmax, ymin:ymax, zmin:zmax) = 1;
 	end

end