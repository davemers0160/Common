% startup file to add the required folders to the matlab path
% copy this file to the HOME/MATLAB folder

disp('Start Up...');
if(ispc)
    cd('D:/Projects/');
    dfd_root = 'D:/Projects/dfd_common/matlab/';
    common_root = 'D:/Common/matlab/';
else
    cd('~/Projects/');
    dfd_root = '~/Projects/dfd_common/matlab/';
    common_root = '~/Common/matlab/';
end

%% dfd root path
listing = dir(dfd_root);
listing = listing(3:end);

addpath(dfd_root,'-begin');
for idx=1:length(listing)   
    if(listing(idx).isdir == 1)
        addpath(fullfile(listing(idx).folder, listing(idx).name),'-begin');
    end    
end

%% cOmmon root path
listing = dir(common_root);
listing = listing(3:end);

addpath(common_root,'-begin');
for idx=1:length(listing)    
    if(listing(idx).isdir == 1)
        addpath(fullfile(listing(idx).folder, listing(idx).name),'-begin');
    end
end

clear idx listing dfd_root common_root
