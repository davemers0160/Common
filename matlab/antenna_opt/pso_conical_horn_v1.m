
format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
commandwindow;

%% PSO params/member setup
pso_params = struct();
pso_params.c1 = 2.4;
pso_params.c2 = 2.1;
pso_params.phi = pso_params.c1 + pso_params.c2;
pso_params.kap = 2/(abs(2 - pso_params.phi - sqrt(pso_params.phi^2 - 4*pso_params.phi)));
pso_params.itr_max = 10;       % number of iterations
pso_params.N = 20;              % population size              
pso_params.ZN = 1;
pso_params.D = 7;
pso_params.min_error = -30;     % objective function value to stop

%% configure the remaining pso elements
    % antennaObject.Radius = 0.012;
    % antennaObject.WaveguideHeight = 0.03;
    % antennaObject.FeedHeight = 0.0075;
    % antennaObject.FeedWidth = 0.003;
    % antennaObject.FeedOffset = 0.01;
    % antennaObject.ConeHeight = 0.05;
    % antennaObject.ApertureRadius = 0.035;

    % antennaObject.Radius = X(1);
    % antennaObject.WaveguideHeight = X(2);
    % antennaObject.FeedHeight = X(3);
    % antennaObject.FeedWidth = X(4);
    % antennaObject.FeedOffset = X(5);
    % antennaObject.ConeHeight = X(6);
    % antennaObject.ApertureRadius = X(7);

% pso_params.position_limits [min; max]
pso_params.position_limits = [0.010, 0.020, 0.005, 0.0009, 0.005, 0.030, 0.010; ...
                              0.030, 0.100, 0.010, 0.0100, 0.050, 0.150, 0.036];

% pso_params.velocity_limits [min; max]
pso_params.velocity_limits = [-0.005, -0.005, -0.001, -0.001, -0.005, -0.005, -0.005; ...
                               0.005,  0.005,  0.001,  0.001,  0.005,  0.005,  0.005];


                           
%% run PSO

% X = {[0.0009, 0.0075, 0.014, 0.028, 0.035, 0.053, 0.062, 0.070, -0.01]}; 
X = {};

[Pg, G, g_best, P, itr, img, X2, F] = pso_2(@conical_horn_objective, pso_params, X);


%%

ant = show_conical_horn_antenna(Pg, 9.35e9);

%%

t = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmmss');

filename = strcat('c:\Projects\data\conical_horn_ant_',char(t),'.mat');

save(filename, 'ant');
