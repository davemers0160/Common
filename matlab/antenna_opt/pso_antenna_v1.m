
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
pso_params.itr_max = 20;       % number of iterations
pso_params.N = 12;              % population size              
pso_params.ZN = 1;
pso_params.D = 9;
pso_params.min_error = -30;     % objective function value to stop

%% configure the remaining pso elements

%     antennaObject.FeedWidth = X(1);
%     antennaObject.FeedHeight = X(2);
%     antennaObject.Height = X(3);
%     antennaObject.Width = X(4);
%     antennaObject.Length = X(5);
%     antennaObject.FlareLength = X(6);
%     antennaObject.FlareHeight = X(7);
%     antennaObject.FlareWidth = X(8);
%     antennaObject.FeedOffset = [X(9) 0];

% pso_params.position_limits [min; max]
pso_params.position_limits = [0.0005, 0.005, 0.008, 0.008, 0.010, 0.030, 0.010, 0.010, -0.020; ...
                              0.0020, 0.010, 0.030, 0.060, 0.080, 0.150, 0.078, 0.078, 0.020];

% pso_params.velocity_limits [min; max]
pso_params.velocity_limits = [-0.0002, -0.001, -0.001, -0.001, -0.001, -0.005, -0.005, -0.005, -0.005; ...
                               0.0002,  0.001,  0.001,  0.001,  0.001,  0.005,  0.005,  0.005,  0.005];


                           
%% run PSO

X = [0.0009, 0.0075, 0.014, 0.028, 0.035, 0.053, 0.062, 0.070, -0.01]; 

[Pg, G, g_best, P, itr, img] = pso_2(@horn_objective, pso_params, X);


%%

show_horn_antenna(Pg, 9.35e9);



