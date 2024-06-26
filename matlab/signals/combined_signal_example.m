format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% combined Signal generation examples

% common parameters
sample_rate = 20e6;

pulse_width = 10e-6;
pri = 20e-6;

num_bits = 4;
bit_length = 5e-7;
    
num_pulses = 4;

f_start = -0.5e6;
f_stop = 0.5e6;

amplitude = 2000;

%% CW

% number of samples for each pulse
samples_per_pulse =  floor(pulse_width * sample_rate);

iq = complex(amplitude*ones(samples_per_pulse,1), zeros(samples_per_pulse,1));

% get the number of samples in the pri
samples_per_pri = floor(pri * sample_rate);

buffer_samples = max(0, samples_per_pri-samples_per_pulse);


% add the buffer on to the end
iq = cat(1,iq, complex(zeros(buffer_samples,1), zeros(buffer_samples,1)));

% concatentate pulses
iq = repmat(iq,num_pulses,1);

x = (0:numel(iq)-1) * (1/sample_rate);

% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
plot(x, real(iq), 'b');
hold on
plot(x, imag(iq), 'r');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');

plot_num  = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
scatter(real(iq), imag(iq), 20, 'o', 'b', 'filled');


set(gca,'fontweight','bold','FontSize',11);

xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

scatter3(x, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
plot3(x, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;



%% LFM

[iq] = generate_lfm(sample_rate, f_start, f_stop, pulse_width).';


% number of samples for each pulse
samples_per_pulse = numel(iq);

% get the number of samples in the pri
samples_per_pri = floor(pri * sample_rate);

buffer_samples = max(0, samples_per_pri-samples_per_pulse);

% add the buffer on to the end
iq = cat(1,iq, complex(zeros(buffer_samples,1), zeros(buffer_samples,1)));

% concatentate pulses
iq = repmat(iq,num_pulses,1);

x = (0:numel(iq)-1) * (1/sample_rate);

% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
plot(x, real(iq), 'b');
hold on
plot(x, imag(iq), 'r');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');

plot_num  = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
scatter(real(iq), imag(iq), 20, 'o', 'b', 'filled');


set(gca,'fontweight','bold','FontSize',11);

xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

scatter3(x, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
plot3(x, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;


%% BPSK - Barker

% barker codes
b5 = [1, 1, 1, -1, 1];

% get the complex IQ data
[iq] = generate_bpsk(b5, amplitude, sample_rate, bit_length);

% number of samples for each pulse
samples_per_pulse = numel(iq);

% get the number of samples in the pri
samples_per_pri = floor(pri * sample_rate);

buffer_samples = max(0, samples_per_pri-samples_per_pulse);


% add the buffer on to the end
iq = cat(1,iq, complex(zeros(buffer_samples,1), zeros(buffer_samples,1)));

% concatentate pulses
iq = repmat(iq,num_pulses,1);

x = (0:numel(iq)-1) * (1/sample_rate);

% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
plot(x, real(iq), 'b');
hold on
plot(x, imag(iq), 'r');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');

plot_num  = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
scatter(real(iq), imag(iq), 20, 'o', 'b', 'filled');


set(gca,'fontweight','bold','FontSize',11);

xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

scatter3(x, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
plot3(x, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;


%% BPSK - MLS

% maximal length sequence
taps = [4,3];
x4 = maxmimal_length_seq(num_bits, taps);

% get the complex IQ data
[iq] = generate_bpsk(x4, amplitude, sample_rate, bit_length);

% number of samples for each pulse
samples_per_pulse = numel(iq);

% get the number of samples in the pri
samples_per_pri = floor(pri * sample_rate);

buffer_samples = max(0, samples_per_pri-samples_per_pulse);

% add the buffer on to the end
iq = cat(1,iq, complex(zeros(buffer_samples,1), zeros(buffer_samples,1)));

% concatentate pulses
iq = repmat(iq,num_pulses,1);

x = (0:numel(iq)-1) * (1/sample_rate);


% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
plot(x, real(iq), 'b');
hold on
plot(x, imag(iq), 'r');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');

plot_num  = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
scatter(real(iq), imag(iq), 20, 'o', 'b', 'filled');


set(gca,'fontweight','bold','FontSize',11);

xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

scatter3(x, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
plot3(x, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;



