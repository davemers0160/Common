format long g
format compact
clc
%close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ~] = fileparts(full_path);
plot_num = 1;

%% set up the parameters for the generation of the IQ data

save_path = startpath;

% sample rate in Hz
sample_rate = 50e6;

% period of iq data in seconds
period = 0.010;

% this is the minimum time resolution in iq
sub_time_step = 50e-7;

% this is the number of samples within a sub_time_step
sample_step_size = floor(sample_rate * sub_time_step);

% the number of sub steps to make a period
sub_step_num = floor(period / sub_time_step + 0.5);

% number of files to generate
N = 4;

% maximum value for "zero" iq
zero_max_value = 1/10000.0;

% calculate the number of samples based on the sample rate and signal time
num_samples = sample_rate * period;

t = (0:num_samples-1)';

% zero_samples = zero_max_value*ones(sample_step_size, 2);
% ones_samples = ones(sample_step_size, 2);


%% run some numbers
itr = 2;
iq_data = cell(N,1);

% generate the initial population
for idx=1:N

    % generate the random steps
    sig_mask = randi([0,1], sub_step_num, 1);
%     sig_mask = sig_mask+zero_max_value;
%     sig_mask(sig_mask>1) = 1;
    
    % add duty cycle
    duty_cycle = min(0.88, max(0.05, floor(1000*rand(1))/1000));
    num_on = num_samples - floor(num_samples*(1-duty_cycle));
    dc_mask = cat(1, zeros(num_samples-num_on,1), ones(floor(num_on),1));
    
    % and the two masks
    %final_mask = (sig_mask .* dc_mask) + zero_max_value;
    %final_mask = (dc_mask) + zero_max_value;
    final_mask = (dc_mask);
    final_mask(final_mask>1) = 1;
%     final_mask = resample(final_mask, sample_step_size, 1, 1);
    
    
%     iq_data{idx} = [];
%     for jdx=1:sub_step_num
%         if(final_mask(jdx) == 1)
%             iq_data{idx} = cat(1, iq_data{idx}, (2*rand(sample_step_size, 2) - 1));
%         else
%             iq_data{idx} = cat(1, iq_data{idx}, zero_max_value*(2*rand(sample_step_size, 2) - 1));
%         end      
%     end
    
    % randomly generate num_samples IQ data in the range (-1, 1)
    %iq_data{idx} = 2*rand(num_samples, 2) - 1; 
    %tmp_iq = 2*pi*sample_rate*(rand(1,num_samples)-0.5);
    tmp_iq2 = [];
    tmp_iq3 = [];
    % generate random samples that range from (-0.5, 0.5] <- represents +/-
    % 1/2 sample_rate
%     tmp_iq = rand(1,sub_step_num) - 0.5;
%     tmp_iq2 = resample(tmp_iq, sample_step_size, 1, 10)';
%     tmp_iq3 = tmp_iq2.*t;
%     iq_data{idx} = cat(2, cos(2*pi*tmp_iq3), sin(2*pi*tmp_iq3));

    tmp_iq = rand(sub_step_num,2) - 0.5;
    tmp_iq2(:,1) = interp1(linspace(0, num_samples-1, sub_step_num), tmp_iq(:,1), (0:1:num_samples-1), 'pchip');
    tmp_iq2(:,2) = interp1(linspace(0, num_samples-1, sub_step_num), tmp_iq(:,2), (0:1:num_samples-1), 'pchip');

%     tmp_iq2(:,1) = resample(tmp_iq(:,1), sample_step_size, 1, 10);
%     tmp_iq2(:,2) = resample(tmp_iq(:,2), sample_step_size, 1, 10);
    %tmp_iq3 = tmp_iq2.*t;
    tmp_iq3 = cumsum(tmp_iq2);
    %tmp_iq3 = tmp_iq2;
    iq_data{idx} = cat(2, cos(2*pi*tmp_iq3(:,1)), sin(2*pi*tmp_iq3(:,1)));
    %iq_data{idx} = cat(2, cos(pi*tmp_iq3(:,1)), sin(pi*tmp_iq3(:,2)));

    
%     tmp_iq3 = resample([-1e7 1e7], num_samples/2, 1, 10)/sample_rate;
%     tmp_iq3 = tmp_iq3'.*t;
    
    %F = linspace(1e6, 2e6, num_samples);
    %iq_data{idx} = cat(2, cos(tmp_iq(:,1)/num_samples), sin(tmp_iq(:,2)/num_samples));
    %iq_data{idx} = cat(2, cos(2*pi*tmp_iq.*F.*(0:num_samples-1)/sample_rate)', sin(2*pi*tmp_iq.*F.*(0:num_samples-1)/sample_rate)');
    %iq_data{idx} = cat(2, cos(2*pi*tmp_iq.*F/sample_rate)', sin(2*pi*tmp_iq.*F/sample_rate)');
    %iq_data{idx} = cat(2, cos(tmp_iq2(:,1))', sin(tmp_iq2(:,1))');
    
    

    iq_data{idx} = iq_data{idx} .* final_mask;
    iq_data_c = complex(iq_data{idx}(:,1), iq_data{idx}(:,2));
    
    % plot the spectrogram of the iq data
    figure(plot_num);
    spectrogram(iq_data_c, 256, 0, 256, sample_rate, 'centered');
    plot_num = plot_num + 1;
    drawnow;
    
    % generate a file_name for the data
    
    file_name = strcat('pso_iq_data_', num2str(itr,'%03d_'), num2str(idx, '%03d'), '.dat');
    
    tic;
    %write_binary_iq_data(fullfile(save_path,file_name), iq_data{idx}, 'double');
    toc
    
end



%% plot the iq data
% figure(plot_num)
% hold on
% grid on
% box on
% plot(real(iq_data), 'b')
% plot(imag(iq_data), 'r')
% 
% plot_num = plot_num + 1;




