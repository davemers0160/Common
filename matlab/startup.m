% startup file to add the required folders to the matlab path
% copy this file to the HOME/MATLAB folder

disp('Start Up...');
cd 'D:/IUPUI/DfD/MATLAB/';

listing = dir;
listing = listing(3:end);

addpath('D:/IUPUI/DfD/MATLAB/','-begin');
for idx=1:length(listing)   
    if(listing(idx).isdir == 1)
        addpath(fullfile(listing(idx).folder, listing(idx).name),'-begin');
    end    
end

listing = dir('D:/Common/matlab/');
listing = listing(3:end);

addpath('D:/Common/matlab/','-begin');
for idx=1:length(listing)    
    if(listing(idx).isdir == 1)
        addpath(fullfile(listing(idx).folder, listing(idx).name),'-begin');
    end
end

clear idx listing
