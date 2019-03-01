
format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);


%% PSO params/member setup
pso_params = struct();
pso_params.c1 = 2.4;
pso_params.c2 = 2.1;
pso_params.phi = pso_params.c1 + pso_params.c2;
pso_params.kap = 2/(abs(2 - pso_params.phi - sqrt(pso_params.phi^2 - 4*pso_params.phi)));
pso_params.itr_max = 20;       % number of iterations
pso_params.N = 20;              % population size              


%% load in the data

file_filter = {'*.xml','XML Files';'*.*','All Files' };
%start_path = 'D:\Common\matlab\gorgon';
start_path = 'D:\IUPUI\PhD\Results\dfd_dnn\dnn_reduction';

[filename, file_path] = uigetfile(file_filter, 'Select XML file', start_path);

if(file_path==0)
    return;
end

commandwindow;
%%
[gorgon_data, gorgon_struct] = read_gorgon_data(fullfile(file_path,filename));
% [file_path,~,~] = fileparts(filename);

%figure out the layer type based on the number of rows and columns
if(gorgon_struct.nr==1 && gorgon_struct.nc==1)
    lt = 1;
else
    lt = 2;
end


data_min = realmax;
data_max = realmin;
z = zeros(gorgon_struct.k, numel(gorgon_data{1}.data(:)));

for idx=1:gorgon_struct.k
    data_min = min(data_min,min(gorgon_data{idx}.data(:)));
    data_max = max(data_max,max(gorgon_data{idx}.data(:)));
    z(idx,:) = gorgon_data{idx}.data(:);
end

%% configure the remaining pso elements

% pso_params.x_lim [min, max]
pso_params.x_lim = [2*data_min, 2*data_max];

% pso_params.v_lim [min max]
pso_params.v_lim = [-1,1];

% 


%% run PSO
[p_best, g_best, P, V, F, G] = run_pso_cluster(z, pso_params);

%%

% for jdx=1:pso_params.N
for idx=1:size(z,1)
    [d{idx,1}, m_idx(idx,1)] = calc_distance(z(idx,:), G{end-1});
end
   
u = unique(m_idx);

fprintf('Uniques Classes: %d\n', numel(u));
    
%     F(jdx, 1) = calc_fitness(d(:,jdx), m_idx(:,jdx));
% end
