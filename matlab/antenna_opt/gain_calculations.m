format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;


%% gain charaterization script

% power loss through the air for a given frequency and distance
path_loss = 63.85;

% this is the power expected if the RF was just through cables
expected_power = -15.2;

%% measured matrix

A = [1,1,0;...
     1,0,1;...
     0,1,1];

b = [-45.0;...
     -44.5;...
     -43.8];

b = b - expected_power + path_loss;
disp(b)

%% Ax = b --> x = A^(-1) * b

% A_inv = At * (A*At)^(-1)

A_inv = (A.') * pinv(A * (A.'));

x = A_inv * b;

disp(x);
