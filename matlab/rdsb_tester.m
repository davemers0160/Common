format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% RDSB Setup

userInput = helperRBDSInit();
userInput.Duration = 40;
% userInput.SignalSource = 'File';
% userInput.SignalFilename = 'rbds_capture.bb';
userInput.SignalSource = 'RTL-SDR';
userInput.CenterFrequency = 97.7e6;
% userInput.SignalSource = 'ADALM-PLUTO';
% userInput.CenterFrequency = 98.5e6;
% userInput.SignalSource = 'USRP';
% userInput.CenterFrequency = 98.5e6;
userInput.RadioAddress = '0';

[rbdsParam, sigSrc] = helperRBDSConfig(userInput)

%% 

fmBroadcastDemod = comm.FMBroadcastDemodulator(...
    'SampleRate',228e3, ...
    'FrequencyDeviation',rbdsParam.FrequencyDeviation, ...
    'FilterTimeConstant',rbdsParam.FilterTimeConstant, ...
    'AudioSampleRate',rbdsParam.AudioSampleRate, ...
    'Stereo',true);

% Create audio player
player = audioDeviceWriter('SampleRate',rbdsParam.AudioSampleRate);

% Layer 2 object
datalinkDecoder = RBDSDataLinkDecoder();

% Layer 3 object
sessionDecoder  = RBDSSessionDecoder();
% register processing implementation for RadioText Plus (RT+) ODA:
rtID = '4BD7';
registerODA( ...
    sessionDecoder,rtID,@RadioTextPlusMainGroup,@RadioTextPlus3A);

% Create the data viewer object
viewer = helperRBDSViewer();

% Start the viewer and initialize radio time
start(viewer)
radioTime = 0;
% Main loop
while radioTime < rbdsParam.Duration
    % Receive baseband samples (Signal Source)
    rcv = sigSrc();

    % Demodulate FM broadcast signals and play the decoded audio
    audioSig = fmBroadcastDemod(rcv);
    player(audioSig);

    % Process physical layer (Layer 1)
    bitsPHY = RBDSPhyDecoder(rcv, rbdsParam);

    % Process data-link layer (Layer 2)
    [enabled,iw1,iw2,iw3,iw4] = datalinkDecoder(bitsPHY);

    % Process session and presentation layer (Layer 3)
    outStruct = sessionDecoder(enabled,iw1,iw2,iw3,iw4);

    % View results packet contents (Data Viewer)
    update(viewer, outStruct);

    % Update radio time
    radioTime = radioTime + rbdsParam.FrameDuration;
end

% Stop the viewer and release the signal source and audio writer
stop(viewer);