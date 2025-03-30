format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;
line_width = 1.0;
cm = ['r', 'g', 'b', 'k'];

commandwindow;

%% setup frequency parameters

% samples per second
sample_rate = 44100;

% frequency to play in Hz
frequency = 10000;

% duration in seconds
tone_duration = 1;

tone_samples = floor(sample_rate * tone_duration);

%% create the signal

t = 0:1:tone_samples;

tone = cos(2*pi*frequency/sample_rate*t);

%% play audio

count = 5;

audio_obj = audioplayer(tone, sample_rate);

for idx=1:count
    play(audio_obj);
end
