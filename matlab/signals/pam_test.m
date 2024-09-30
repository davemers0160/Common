format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;

%% parameters

beta = 0.6;
span = 7;
sample_rate = 50e6;
symbol_length = 0.001;
scale = 1;
amplitude = 2000;

samples_per_symbol = floor(sample_rate*symbol_length + 0.5);

b = rcosdesign(beta, span, samples_per_symbol,'sqrt');

[g] = create_rrc_filter(span, beta, symbol_length, sample_rate, scale);

figure(plot_num)
plot(b, 'b')
hold on;
plot(g, 'g')
plot_num = plot_num + 1;


%%

num_data = 40;
data = randi([0,1], num_data, 1);

[iq_data] = generate_4pam(data, amplitude, symbol_length, sample_rate);

tic
iq2 = conv(iq_data, g, 'same');
toc

figure(plot_num);
plot(iq2*80); 
hold on; 
plot(iq_data)
plot_num = plot_num + 1;

%%


N=span/2;

% get the data +/- 1 symbol
rrc_trunc = g(ceil(numel(g)/2)-N*samples_per_symbol:floor(numel(g)/2)+ N*samples_per_symbol+1);

data2 = iq_data(1:samples_per_symbol:end);
num_data2 = numel(data2);

d2 = zeros(1, samples_per_symbol*(num_data2+2*N)+1);

tic
index = N*samples_per_symbol;

for idx = 1:num_data2

    d2(index-N*samples_per_symbol+1:index+N*samples_per_symbol+1) = d2(index-N*samples_per_symbol+1:index+N*samples_per_symbol+1) + rrc_trunc * data2(idx);
    index = index + samples_per_symbol;
end
toc

figure(plot_num);
plot(d2*80,'b'); 
hold on; 
plot(cat(1,zeros(N*samples_per_symbol,1),iq2*80),'g'); 
plot(cat(1,zeros(N*samples_per_symbol,1),iq_data),'r');
plot_num = plot_num + 1;
