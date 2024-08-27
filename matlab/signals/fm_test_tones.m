format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;

%% create tone sequence params

sample_rate = 882000;

test_tones = [400:400:10000];

tone_length = 1;

%% generate audio

audio_data = [];

for idx=1:numel(test_tones)

    audio_data = cat(1, audio_data, sin(2*pi*(test_tones(idx)/sample_rate)*(0:1:sample_rate-1)).');

end

%%

num_taps = 5;
w = blackman_nuttall_window(num_taps);
lpf = create_fir_filter(0.6, w);
apf = create_fir_filter(1.0, w);
hpf = 8*(apf-0.99*lpf);

fvtool(hpf)

audio_data_f = conv(audio_data, 8*hpf(end:-1:1));

figure;
plot(audio_data)
hold on
plot(audio_data_f)

%% generate FM

k = 0.01;

% [iq_data] = generate_fm(audio_data_f, sample_rate, sample_rate, k);

fmmod1 = comm.FMModulator(SampleRate=sample_rate, FrequencyDeviation=10000);
iq_data = fmmod1(audio_data_f);

num_taps = 301;
w = blackman_nuttall_window(num_taps);
lpf = create_fir_filter(12000/sample_rate, w);

iq_data = conv(iq_data, lpf(end:-1:1));

iq_data = complex(int16(1800*(iq_data)));

figure;
spectrogram(double(iq_data)/2048, 2048,1024,2048,sample_rate, 'centered');

figure;
plot(real(iq_data), 'b')
hold on
plot(imag(iq_data), 'r')


%%
data_type = 'int16';
byte_order = 'ieee-le';

filename = 'D:\Projects\data\RF\test_tones2_882k000.sc16';

write_binary_iq_data(filename, iq_data, data_type, byte_order);

fprintf('complete\n');





