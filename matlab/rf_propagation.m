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
% clear tempdir
% setenv('TMP','C:/temper');

commandwindow;

%% conversions

ft2m = 0.3048001109472;
m2nmi = 0.000539957;
yd2m = 0.9144;
m2yd = 1/yd2m;
m2ft = 1/ft2m;

%% setup propagation model
sw_conductivity = 5.5;
sw_permitivity = 68;

pm_lr = propagationModel("longley-rice", 'ClimateZone', 'maritime-over-sea', 'GroundPermittivity', sw_permitivity, 'GroundConductivity', sw_conductivity);
pm_fsl = propagationModel("freespace");

%% tx parameters
latitude = 42.0;
longitude = -68.0;
tx_antenna_height = 3*ft2m;          % meters
tx_power = 1;                       % Watts
tx_freq = 1000e6;                   % Hz

tx = txsite('Name','M', 'Latitude', latitude, 'Longitude', longitude, 'TransmitterFrequency',tx_freq, 'TransmitterPower',tx_power, 'AntennaHeight',tx_antenna_height);

%% rx parameters

latitude = linspace(42.000, 42.08, 201);
longitude = -68.0*ones(numel(latitude),1);
rx_antenna_height = 1.7*ft2m;       % meters
rx_sensitivity = -200;              % dBm

rx = rxsite('Name','R', 'Latitude', latitude, 'Longitude', longitude, 'ReceiverSensitivity',rx_sensitivity, 'AntennaHeight',rx_antenna_height);

%% coverage map

transparency = 0.6;
rx_height = 50;                     % meters
signal_strength = -130:5:-20;       % dBm
max_range = 3e5;                    % meters
rx_gain = 0;                        % dB

coverage(tx, "PropagationModel", pm_fsl, 'MaxRange',max_range, 'SignalStrengths',signal_strength, 'ReceiverGain',rx_gain, 'Transparency',transparency, 'ReceiverAntennaHeight',rx_height);

%% try pathloss
wgs84 = wgs84Ellipsoid("m");
for idx=1:numel(rx)
    d(1,idx) = distance(tx.Latitude, tx.Longitude, rx(idx).Latitude, rx(idx).Longitude, referenceEllipsoid('GRS 1980'));
end

viewer = siteviewer;
% pl_fsl = pathloss(pm_fsl, rx, tx);
for idx=1:numel(rx)
    pl_lr(1,idx) = pathloss(pm_lr, rx(idx), tx, 'Map',viewer);
end
%% plot

x_min = 0;
x_max = 120;
y_min = -165;
y_max = -15;

figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')
% plot(m2nmi*d, -pl_fsl, '.-b', 'LineWidth', line_width);
box on
grid on
hold on
plot(d, -pl_lr, '.-g', 'LineWidth', line_width);
plot([x_min,x_max], [-120, -120], '--g', 'LineWidth', line_width);

set(gca,'fontweight','bold','FontSize', 13);

xlim([x_min,x_max])
xticks(x_min:5:x_max)
ylim([y_min, y_max])
yticks([y_min:5:y_max])

xlabel('Slant Range (nmi)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Pathloss (dB)', 'fontweight', 'bold', 'FontSize', 13);

title(strcat('Propagation Results: Tx Height =',32,num2str(floor(tx.AntennaHeight/ft2m+0.5), '%5d ft;'),32, 'Rx Height =',32,num2str(floor(rx(1).AntennaHeight/ft2m+0.5), '%5d ft')), 'fontweight', 'bold', 'FontSize', 14);

legend('PathLoss','Min RSL');

ax = gca;
ax.Position = [0.06, 0.085, 0.9, 0.85];

plot_num = plot_num + 1; 
