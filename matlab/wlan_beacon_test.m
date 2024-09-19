format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;

%% Create IEEE 802.11 Beacon Frame

% create the SSID
ssid = "TEST_BEACON";

% number of 1.024ms time increments between messages
beaconInterval = 10;

%
band = 2.4;

%
chNum = 1;

mc_id = "083a8d40556c";

% Create a MAC frame-body configuration object, setting the SSID and Beacon Interval field value
frameBodyConfig = wlanMACManagementConfig(BeaconInterval=beaconInterval, SSID=ssid);

% Add the DS Parameter information element (IE) to the frame body by using the addIE object function
dsElementID = 3;
dsInformation = dec2hex(chNum, 2);
frameBodyConfig = frameBodyConfig.addIE(dsElementID, dsInformation);
frameBodyConfig.displayIEs

% Create beacon frame configuration object
beaconFrameConfig = wlanMACFrameConfig(FrameType="Beacon", ManagementConfig=frameBodyConfig, FromDS=false, AckPolicy="Normal Ack/Implicit Block Ack Request", Address1=mc_id);
% beaconFrameConfig = wlanMACFrameConfig(FrameType="ACK", ManagementConfig=frameBodyConfig, FromDS=false, AckPolicy="Normal Ack/Implicit Block Ack Request");

% Generate beacon frame bits
[mpduBits,mpduLength] = wlanMACFrame(beaconFrameConfig, OutputFormat="bits");
payload = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
% [mpduBits,mpduLength] = wlanMACFrame(payload, beaconFrameConfig, OutputFormat="bits");

% Calculate center frequency for the specified operating band and channel number
fc = wlanChannelFrequency(chNum, band)

%% Create IEEE 802.11 Beacon Packet
% Configure a non-HT beacon packet with the relevant PSDU length, specifying a channel bandwidth of 20 MHz, 
% one transmit antenna, and BPSK modulation with a coding rate of 1/2 (corresponding to MCS index 0) by using 
% the wlanNonHTConfig object.

cfgNonHT = wlanNonHTConfig(PSDULength=mpduLength, MCS=0);
cfgHE = wlanHESUConfig('ChannelBandwidth','CBW20');

% Generate an oversampled beacon packet by using the wlanWaveformGenerator function, specifying an idle time
osf = 2;
tbtt = beaconInterval*1024e-6;
txWaveform = wlanWaveformGenerator(mpduBits, cfgNonHT, OversamplingFactor=osf, Idletime=tbtt);

% Get the waveform sample rate
fs = wlanSampleRate(cfgNonHT, OversamplingFactor=osf)

%% Save Waveform to File

max_v = max(max(abs(real(txWaveform))),max(abs(imag(txWaveform))));

iq_data = complex(int16((1600/max_v)*(txWaveform)));

data_type = 'int16';
byte_order = 'ieee-le';

filename = 'D:\Projects\data\RF\wl_test_F5G260_SR40M000.sc16';
% filename = 'C:\Projects\data\RF\test_rds_ml.sc16';
% filename = 'D:\data\RF\test_rds_ml.sc16';

write_binary_iq_data(filename, iq_data, data_type, byte_order);

fprintf('complete\n');


%% 
ts = 1/fs;

figure;
plot3(ts*(0:1:4322-1), real(iq_data(1:4322)), imag(iq_data(1:4322)), '.-b')

%% 
figure
spectrogram(txWaveform, 512, 300, 512, fs, 'centered');

