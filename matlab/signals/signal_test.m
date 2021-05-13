format long g
format compact
clc
close all
clearvars
global startpath

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);
plot_count = 1;

%% generate the base pulse train

x = maxmimal_length_seq(5);
x_length = length(x);

% start offset
start = 50;

% number of samples to place between pulses
pulse_spacing = 100 - x_length;

% number of pulses
pulse_num = 12;

% build the pulse train
space = zeros(1, pulse_spacing);
signal = repmat([x space], 1, pulse_num);
signal = [zeros(1, start) signal];


%% generate 4 pulse trains that vary in start time
num = 4;
max_offset = 100;

% generate a random offset
off = [];
while(length(off) < num) 
    off = unique(randi([0,max_offset], num, 1), 'stable');
end

% create the signals with some noise
for idx=1:num
    
    % generate noise
    noise = 0.7*randn(1,length(signal) + max_offset);
    
    % build the signal
    sn(idx, :) = [zeros(1, off(idx)) signal zeros(1, max_offset-off(idx))]  + noise;
    
end

%% run the correlation
for idx=1:num
    ryx(idx, :) = conv(sn(idx, :), x(end:-1:1));
end


%% run a blind correlation


bxy = cell(size(sn,1),size(sn,1));

for idx=1:size(sn,1)
    for jdx=1:size(sn,1)
        if jdx ~= idx
            %bxy{idx,jdx} = conv(sn(idx, 1:200), x(end:-1:1));
            bxy{idx,jdx} = conv(sn(idx, 1:200), sn(jdx, 200:-1:1));
        end
    end
end





