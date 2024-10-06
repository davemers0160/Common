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

beta = 0.9;
span = 9;
sample_rate = 1e6;
symbol_length = 0.001;
scale = 20;
amplitude = 2000;

samples_per_symbol = floor(sample_rate*symbol_length + 0.5);

b = rcosdesign(beta, span, samples_per_symbol,'sqrt');

[g] = create_rrc_filter(span, beta, symbol_length, sample_rate, scale);

N = span*samples_per_symbol + 1;
t=linspace((0 - ((N - 1)/2)),((N-1) - ((N - 1)/2)), N);

figure(plot_num)
plot(t, b, 'b')
hold on;
plot(t, g, 'g')
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

samples_per_symbol/(4*beta)

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

% d3 = conv(d2, (1/9)*[1,1,1,1,1,1,1,1,1], 'same');
toc

%% fft test
rrc_fft = fft(g, numel(iq_data)).';

tic
iq_fft = fft(iq_data);

tmp = iq_fft .* rrc_fft;

d3 = ifft(tmp);

toc


%%
figure(plot_num);
plot(d2,'b'); 
hold on; 
plot(cat(1,zeros(N*samples_per_symbol,1),iq2),'g'); 
plot(cat(1,zeros(N*samples_per_symbol,1),iq_data),'r');
plot((d3),'m'); 
plot_num = plot_num + 1;
