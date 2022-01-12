format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

% borrowed from: https://github.com/gkbrk/apt-encoder/blob/master/apt-encode.cpp

%% constants

% Constants and config
CARRIER = 2400;
BAUD = 4160;
OVERSAMPLE = 3;

% Sync words for the left and right images
SYNCA = [0,0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0];
SYNCB = [0,0,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0];

sig_idx = 0;

%% load in image




%% reshape image




%% create lines

buffer = []; %zeros(OVERSAMPLE*numel(SYNCA));

for idx=1:numel(SYNCA)
    [buf, sig_idx] = modulate_signal(255*SYNCA(idx), sig_idx, CARRIER, OVERSAMPLE, BAUD);
    buffer = cat(1, buffer, buf);

end

for idx=1:47
    [buf, sig_idx] = modulate_signal(0, sig_idx, CARRIER, OVERSAMPLE, BAUD);
    buffer = cat(1, buffer, buf);

end

for idx=1:256
    [buf, sig_idx] = modulate_signal(idx-1, sig_idx, CARRIER, OVERSAMPLE, BAUD);
    buffer = cat(1, buffer, buf);

end

%% modulate signal




%% save as raw binary - 32-bit float



%% extra functions

function [buffer, sig_idx] = modulate_signal(value, sig_idx, CARRIER, OVERSAMPLE, BAUD) 

    buffer = zeros(OVERSAMPLE,1);
    
    for idx=1:OVERSAMPLE
        
        samp = sin(CARRIER * 2.0 * pi() * (sig_idx / (BAUD * OVERSAMPLE)));
        
        %map_value(F value, F f1, F t1, T f2, T t2) 
        %return f2 + ((t2 - f2) * (value - f1)) / (t1 - f1);
        samp = samp * (0.0 + ((0.8 - 0.0) * (value - 0.0)) / (255 - 0.0));   %map_value((int)value, 0(f1), 255(t1), 0.0(f2), 0.7(t2));

%         uint8_t buf = map_value(samp, -1.0, 1.0, 0, 255);
%         buffer.push_back(buf);
        
        buffer(idx) = floor((0 + ((255 - 0.0) * (samp +1)) / (1+1)));

        sig_idx = sig_idx + 1;
    end

    
    
end 


