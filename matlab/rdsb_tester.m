format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;
line_width = 1;

commandwindow;

%%
samples_per_symbol = 24;
groups_per_frame = 19;
program_identification_code = [0 1 1 1 0 0 1 0 1 1 0 0 0 0 0 0];

waveform_biphase = [165, 167, 168, 168, 167, 166, 163, 160,157, 152, 147, 141, 134, 126, 118, 109,99, 88, 77, 66, 53, 41, 27, 14,...
        0, -14, -29, -44, -59, -74, -89, -105,-120, -135, -150, -165, -179, -193, -206, -218,-231, -242, -252, -262, -271, -279, -286, -291,...
        -296, -299, -301, -302, -302, -300, -297, -292,-286, -278, -269, -259, -247, -233, -219, -202,-185, -166, -145, -124, -101, -77, -52, -26,0, 27, 56, 85, 114, 144, 175, 205,...
        236, 266, 296, 326, 356, 384, 412, 439,465, 490, 513, 535, 555, 574, 590, 604,616, 626, 633, 637, 639, 638, 633, 626,616, 602, 586, 565, 542, 515, 485, 451,...
        414, 373, 329, 282, 232, 178, 121, 62,0, -65, -132, -202, -274, -347, -423, -500,-578, -656, -736, -815, -894, -973, -1051, -1128,-1203, -1276, -1347, -1415, -1479, -1540, -1596, -1648,...
        -1695, -1736, -1771, -1799, -1820, -1833, -1838, -1835,-1822, -1800, -1767, -1724, -1670, -1605, -1527, -1437,-1334, -1217, -1087, -943, -785, -611, -423, -219,...
        0, 235, 487, 755, 1040, 1341, 1659, 1994,2346, 2715, 3101, 3504, 3923, 4359, 4811, 5280,5764, 6264, 6780, 7310, 7856, 8415, 8987, 9573,10172, 10782, 11404, 12036, 12678, 13329, 13989, 14656,...
        15330, 16009, 16694, 17382, 18074, 18767, 19461, 20155,20848, 21539, 22226, 22909, 23586, 24256, 24918, 25571,26214, 26845, 27464, 28068, 28658, 29231, 29787, 30325,30842, 31339, 31814, 32266, 32694, 33097, 33473, 33823,...
        34144, 34437, 34699, 34931, 35131, 35299, 35434, 35535,35602, 35634, 35630, 35591, 35515, 35402, 35252, 35065,34841, 34579, 34279, 33941, 33566, 33153, 32702, 32214,31689, 31128, 30530, 29897, 29228, 28525, 27788, 27017,...
        26214, 25379, 24513, 23617, 22693, 21740, 20761, 19755,18725, 17672, 16597, 15501, 14385, 13251, 12101, 10935,9755, 8563, 7360, 6148, 4927, 3701, 2470, 1235,0, -1235, -2470, -3701, -4927, -6148, -7360, -8563,...
        -9755, -10935, -12101, -13251, -14385, -15501, -16597, -17672,-18725, -19755, -20761, -21740, -22693, -23617, -24513, -25379,-26214, -27017, -27788, -28525, -29228, -29897, -30530, -31128,-31689, -32214, -32702, -33153, -33566, -33941, -34279, -34579,...
        -34841, -35065, -35252, -35402, -35515, -35591, -35630, -35634,-35602, -35535, -35434, -35299, -35131, -34931, -34699, -34437,-34144, -33823, -33473, -33097, -32694, -32266, -31814, -31339,-30842, -30325, -29787, -29231, -28658, -28068, -27464, -26845,...
        -26214, -25571, -24918, -24256, -23586, -22909, -22226, -21539,-20848, -20155, -19461, -18767, -18074, -17382, -16694, -16009,-15330, -14656, -13989, -13329, -12678, -12036, -11404, -10782,-10172, -9573, -8987, -8415, -7856, -7310, -6780, -6264,...
        -5764, -5280, -4811, -4359, -3923, -3504, -3101, -2715,-2346, -1994, -1659, -1341, -1040, -755, -487, -235,0, 219, 423, 611, 785, 943, 1087, 1217,1334, 1437, 1527, 1605, 1670, 1724, 1767, 1800,...
        1822, 1835, 1838, 1833, 1820, 1799, 1771, 1736,1695, 1648, 1596, 1540, 1479, 1415, 1347, 1276,1203, 1128, 1051, 973, 894, 815, 736, 656,578, 500, 423, 347, 274, 202, 132, 65,...
        0, -62, -121, -178, -232, -282, -329, -373,-414, -451, -485, -515, -542, -565, -586, -602,-616, -626, -633, -638, -639, -637, -633, -626,-616, -604, -590, -574, -555, -535, -513, -490,...
        -465, -439, -412, -384, -356, -326, -296, -266,-236, -205, -175, -144, -114, -85, -56, -27,0, 26, 52, 77, 101, 124, 145, 166,185, 202, 219, 233, 247, 259, 269, 278,...
        286, 292, 297, 300, 302, 302, 301, 299,296, 291, 286, 279, 271, 262, 252, 242,231, 218, 206, 193, 179, 165, 150, 135,120, 105, 89, 74, 59, 44, 29, 14,0, -14,...
        -27, -41, -53, -66, -77, -88,-99, -109, -118, -126, -134, -141, -147, -152,-157, -160, -163, -166, -167, -168, -168, -167];

%%
rbdsgen = comm.RBDSWaveformGenerator(SamplesPerSymbol=samples_per_symbol, GroupsPerFrame=groups_per_frame, RadioText='All Day, All Night!', ...
    ProgramServiceName='TST_RDIO', ProgramIdentificationCode=program_identification_code, ProgramType="Rock")

Y = step(rbdsgen).';

figure(plot_num);
plot(Y, '.-b')
plot_num = plot_num + 1;

%% upsample

factor = 40;

sample_rate = samples_per_symbol * factor * 1187.5;

fprintf('sample rate: %d\n', sample_rate);

rbds_up = upsample(Y, factor);

N = 4*factor + 1;

w = blackman_nuttall_window(N);

% create the full filter using the window
lpf = N*create_fir_filter(2375/sample_rate, w);

% rolloff = 1;
% no_of_symbols = 10;
% lpf = rcosdesign(rolloff, no_of_symbols, (samples_per_symbol * factor) );

% apply the filter to the bpsk signal
rbds_conv = 2*conv(rbds_up, lpf(end:-1:1), 'same');

figure(plot_num);
plot(rbds_up, '-b')
hold on
box on
grid on
plot(rbds_conv, '-g')
plot_num = plot_num + 1;


%%
pilot_amplitude = 0.05;
pilot_freq = 19000;

stereo_freq = pilot_freq*2;
stereo_amplitude = 0.05;

rbds_freq = 57000;
rbds_amplitude = 0.3;


% pilot_tone = (800*exp(1i*2*pi()*(pilot_freq/sample_rate)*(0:1:numel(rbds_conv)-1)));
% rbds_rot = exp(1i*2*pi()*(rbds_freq/sample_rate)*(0:1:numel(rbds_conv)-1));

% rbds_conv_c = complex(rbds_conv);
% iq_rbds = (rbds_conv_c .* rbds_rot);

% iq_data = int16(pilot_tone + iq_rbds);

% real value only
pilot_tone = pilot_amplitude*cos(2*pi()*(pilot_freq/sample_rate)*(0:1:numel(rbds_conv)-1));
stereo_tone = stereo_amplitude*cos(2*pi()*(stereo_freq/sample_rate)*(0:1:numel(rbds_conv)-1));
rbds_rot = cos(2*pi()*(rbds_freq/sample_rate)*(0:1:numel(rbds_conv)-1));

% complex value
% pilot_tone = pilot_amplitude*exp(2*1i*pi()*(pilot_freq/sample_rate)*(0:1:numel(rbds_conv)-1));
% stereo_tone = stereo_amplitude*exp(2*1i*pi()*(stereo_freq/sample_rate)*(0:1:numel(rbds_conv)-1));
% rbds_rot = exp(2*1i*pi()*(rbds_freq/sample_rate)*(0:1:numel(rbds_conv)-1));

iq_rbds = rbds_amplitude*(rbds_conv .* rbds_rot);

% iq_data = complex(int16(1000*(pilot_tone + stereo_tone + iq_rbds)));
iq_data = complex(int16(800*(pilot_tone + iq_rbds)));


figure(plot_num);
plot(real(iq_rbds), '-b')
plot_num = plot_num + 1;

max(real(iq_data))
max(imag(iq_data))
min(real(iq_data))
min(imag(iq_data))

%%
fft_rbds = fft(double(iq_data)/2048)/numel(iq_data);

x_rbds = linspace(-sample_rate/2, sample_rate/2, numel(fft_rbds));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_rbds/1e3, 20*log10(abs(fftshift(fft_rbds))),'k')
% plot(x_rbds/1e6, 20*log10(abs(fftshift(fft_x1))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_rbds(1), x_rbds(end)]/1e3);
xlabel('Frequency (KHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Filtered vs. Un-Filtered Signal', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;

%%
data_type = 'int16';
byte_order = 'ieee-le';

filename = 'D:\Projects\data\RF\test_rds_ml.sc16';

write_binary_iq_data(filename, iq_data, data_type, byte_order);

fprintf('complete\n');

%%
return;
fname = 'D:\Projects\data\RF\test_rds3.bb';

bbw = comm.BasebandFileWriter(fname, sample_rate, 101.7e6);

tmp = single(pilot_tone + iq_rbds).';

tmp = tmp/(max(abs(tmp)));

bbw(tmp)

release(bbw);


