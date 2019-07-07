% startup file to add the required folders to the matlab path
% copy this file to the HOME/MATLAB folder

disp('Start Up...');
if(ispc)
    dfd_root = 'D:/IUPUI/DfD/MATLAB/';
    common_root = 'D:/Common/matlab/';

else
    dfd_root = '~/DfD/MATLAB/';
    common_root = '~/Common/matlab/';
end


cd(dfd_root);

listing = dir;
listing = listing(3:end);

addpath(dfd_root,'-begin');
for idx=1:length(listing)   
    if(listing(idx).isdir == 1)
        addpath(fullfile(listing(idx).folder, listing(idx).name),'-begin');
    end    
end

listing = dir(common_root);
listing = listing(3:end);

addpath(common_root,'-begin');
for idx=1:length(listing)    
    if(listing(idx).isdir == 1)
        addpath(fullfile(listing(idx).folder, listing(idx).name),'-begin');
    end
end

clear idx listing dfd_root common_root
