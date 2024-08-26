%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:

format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 17);


% Specify column names and types
opts.VariableNames = ["Var1", "VarName2", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14", "VarName15", "VarName16", "VarName17"];
opts.SelectedVariableNames = ["VarName2", "VarName15", "VarName16", "VarName17"];
opts.VariableTypes = ["char", "double", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, ["Var1", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14"], "EmptyFieldRule", "auto");

filename = fullfile(scriptpath,"data_collect_20240825.xlsx");

%% Specify sheet and range
opts.Sheet = "baseline_20240825";
opts.DataRange = "A1:Q3003";

% Import the data
datacollect20240825S1 = readtable(filename, opts, "UseExcel", false);

%Convert to output type
baseline = table2array(datacollect20240825S1);

%% Specify sheet and range
opts.Sheet = "payload_on_20240825";
opts.DataRange = "A1:Q4510";

% Import the data
datacollect20240825S1 = readtable(filename, opts, "UseExcel", false);

%Convert to output type
payload_on = table2array(datacollect20240825S1);

%% Specify sheet and range
opts.Sheet = "payload_on_RF_on_20240825";
opts.DataRange = "A1:Q4510";

% Import the data
datacollect20240825S1 = readtable(filename, opts, "UseExcel", false);

%Convert to output type
payload_on_rf_on = table2array(datacollect20240825S1);

%% Specify sheet and range
opts.Sheet = "shielded_payload_on_20240825";
opts.DataRange = "A1:Q5006";

% Import the data
datacollect20240825S1 = readtable(filename, opts, "UseExcel", false);

%Convert to output type
payload_on_rf_on_shield = table2array(datacollect20240825S1);

%% Specify sheet and range
opts.Sheet = "shielded_moved_payload_on_20240";
opts.DataRange = "A1:Q4326";

% Import the data
datacollect20240825S1 = readtable(filename, opts, "UseExcel", false);

%Convert to output type
payload_on_rf_on_shield_move = table2array(datacollect20240825S1);

%% Clear temporary variables
clear opts datacollect20240825S1

%%
mean_lat = mean(baseline(:,2));
mean_long = mean(baseline(:,3));
mean_alt = mean(baseline(:,4));

lat_deg_conv = 111111;
long_deg_conv = 111111;% * cosd(mean_long);

baseline_dev = [lat_deg_conv*(baseline(:,2)-mean_lat), long_deg_conv*(baseline(:,3)-mean_long), baseline(:,4)-mean_alt];

payload_on_rf_on_dev = [lat_deg_conv*(payload_on_rf_on(:,2)-mean_lat), long_deg_conv*(payload_on_rf_on(:,3)-mean_long), payload_on_rf_on(:,4)-mean_alt];

payload_on_rf_on_shield_dev = [lat_deg_conv*(payload_on_rf_on_shield(:,2)-mean_lat), long_deg_conv*(payload_on_rf_on_shield(:,3)-mean_long), payload_on_rf_on_shield(:,4)-mean_alt];

payload_on_rf_on_shield_move_dev = [lat_deg_conv*(payload_on_rf_on_shield_move(:,2)-mean_lat), long_deg_conv*(payload_on_rf_on_shield_move(:,3)-mean_long), payload_on_rf_on_shield_move(:,4)-mean_alt];



%%
figure;
set(gcf,'position',([50,50,1400,800]),'color','w')
scatter(baseline_dev(:,2), baseline_dev(:,1), 15, 'b', 'o', 'filled');
hold on
grid on
box on


scatter(payload_on_rf_on_dev(:,2), payload_on_rf_on_dev(:,1), 15, 'k', 'o', 'filled');
scatter(payload_on_rf_on_shield_dev(:,2), payload_on_rf_on_shield_dev(:,1), 15, 'r', 'o', 'filled');
scatter(payload_on_rf_on_shield_move_dev(:,2), payload_on_rf_on_shield_move_dev(:,1), 15, 'g', 'o', 'filled');

set(gca,'fontweight','bold','FontSize', 13);

xlim([-10,10]);
ylim([-10,10]);

xlabel('X (m)', 'fontweight','bold','FontSize',12);
ylabel('Y (m)', 'fontweight','bold','FontSize',12);

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

legend({'Baseline','Payload On, RF On','Payload On, RF On, Shielded','Payload On, RF On, Shielded, 1.75in Offset'}, 'fontweight','bold','FontSize',12, 'location', 'southoutside', 'Orientation','horizontal');



