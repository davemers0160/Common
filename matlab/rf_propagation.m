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
ft2m = 0.3048001109472;
m2nmi = 0.000539957;

commandwindow;

%% setup propagation model
sw_conductivity = 5.5;
sw_permitivity = 68;

pm_lr = propagationModel("longley-rice", 'ClimateZone', 'maritime-over-sea', 'GroundPermittivity', sw_permitivity, 'GroundConductivity', sw_conductivity);
pm_fsl = propagationModel("freespace");


%% tx parameters
latitude = 42.0;
longitude = -68.0;
tx_antenna_height = 40000*ft2m;          % meters
tx_power = 1;                       % Watts
tx_freq = 1000e6;                   % Hz

tx = txsite('Name','M', 'Latitude', latitude, 'Longitude', longitude, 'TransmitterFrequency',tx_freq, 'TransmitterPower',tx_power, 'AntennaHeight',tx_antenna_height);

%% rx parameters

latitude = linspace(42.000, 43.5, 151);
longitude = -68.0*ones(numel(latitude),1);
rx_antenna_height = 145*ft2m;       % meters
rx_sensitivity = -200;              % dBm

rx = rxsite('Name','R', 'Latitude', latitude, 'Longitude', longitude, 'ReceiverSensitivity',rx_sensitivity, 'AntennaHeight',rx_antenna_height);

%% coverage map

transparency = 0.6;
rx_height = 50;                     % meters
signal_strength = -130:5:-20;       % dBm
max_range = 3e5;                    % meters
rx_gain = 0;                        % dB

% coverage(tx, "PropagationModel", pm, 'MaxRange',max_range, 'SignalStrengths',signal_strength, 'ReceiverGain',rx_gain, 'Transparency',transparency, 'ReceiverAntennaHeight',rx_height);

%% try pathloss
d = distance(tx, rx);

pl_fsl = pathloss(pm_fsl, rx, tx);
% pl_lr = pathloss(pm_lr, rx, tx);

%% plot
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(m2nmi*d, -pl_fsl, '.-b', 'LineWidth', line_width);
box on
grid on
hold on
% plot(m2nmi*d, 93-pl_lr, '.-g', 'LineWidth', line_width);

set(gca,'fontweight','bold','FontSize', 13);

xlim([0,90])
xticks(0:5:90)
% ylim([-150, -50])

xlabel('Distance (nmi)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Pathloss (dB)', 'fontweight', 'bold', 'FontSize', 13);

title(strcat('Propagation Results: Tx Height =',32,num2str(floor(tx.AntennaHeight/ft2m+0.5), '%5d ft;'),32, 'Rx Height =',32,num2str(floor(rx(1).AntennaHeight/ft2m+0.5), '%5d ft')), 'fontweight', 'bold', 'FontSize', 14);

ax = gca;
ax.Position = [0.06, 0.11, 0.9, 0.80];

plot_num = plot_num + 1; 
