% startup file to add the required folders to the matlab path
% copy this file to the HOME/MATLAB folder

fprintf('Start Up...\n\n');

fprintf('Setting code root folders...\n');
if(ispc)
    root_dir = 'C:';
    cd(strcat(root_dir, '/Projects/'));
    dfd_root = strcat(root_dir, '/Projects/dfd/common/matlab/');
    common_root = strcat(root_dir, '/Projects/Common/matlab/');
else
    cd('~/Projects/');
    dfd_root = '~/Projects/dfd/common/matlab/';
    common_root = '~/Projects/Common/matlab/';
end

%% dfd root path
listing = dir(dfd_root);
listing = listing(3:end);

fprintf('Adding %s to path...\n', dfd_root);

addpath(dfd_root,'-begin');
for idx=1:length(listing)   
    if(listing(idx).isdir == 1)
        addpath(fullfile(listing(idx).folder, listing(idx).name),'-begin');
    end    
end

%% common root path
listing = dir(common_root);
listing = listing(3:end);

fprintf('Adding %s to path...\n', common_root);

addpath(common_root,'-begin');
for idx=1:length(listing)    
    if(listing(idx).isdir == 1)
        addpath(fullfile(listing(idx).folder, listing(idx).name),'-begin');
    end
end

fprintf('Current directory: %s\n\n', pwd);

clear root_dir idx listing dfd_root common_root
