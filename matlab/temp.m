format long g
format compact
clc
close all
clearvars

lib_path = 'D:\Projects\mnist_dll\build\Release\';
lib_name = 'MNIST_DLL';
hfile = 'D:\Projects\mnist_dll\include\mnist_dll.h';

[notfound, warnings] = loadlibrary(fullfile(lib_path, strcat(lib_name,'.dll')), hfile);

%[notfound, warnings] = loadlibrary(libname, hfile, 'mfilename','mnist_proto');

libisloaded(lib_name)
% unloadlibrary(lib_name); 'MNIST_DLL'

% libfunctions(lib_name)
% libfunctionsview(lib_name)

calllib('MNIST_DLL','init_net','D:/Projects/mnist_dll/nets/mnist_net_pso_14_97.dat');

%% run the net
img = rgb2gray(imread('D:\Projects\mnist\data\test\2_28.png'))';
img2 = img(:);

[res] = calllib(lib_name, 'run_net', img2, 28, 28);

f0 = figure('Units', 'normalized', 'Position', [0.0000 0.7700 0.1 0.15]);
image(img.');
colormap(gray(256));
axis off
ax = gca;
ax.Position = [0 0 1 1];

%%

layer_struct = struct('k', 0, 'n',0, 'nr', 0, 'nc', 0, 'size',0);

data = [];
layer_data1 = libpointer('singlePtr', []);

[layer_struct1] = calllib(lib_name,'get_layer_01', layer_struct, layer_data1);

layer_data1.reshape(layer_struct1.n,layer_struct1.k);
layer_data1.Value

f1 = figure('Units', 'normalized', 'Position', [0.5800 0.0400 0.2900 0.4200]);
hold on
box on
grid on
b1 = bar([0:1:layer_struct1.k-1], layer_data1.Value, 'FaceColor', [0.5, 0.5, 0.5]);
b2 = bar(res, layer_data1.Value(res+1), 'FaceColor','r');


%%
ld_02 = libpointer('singlePtr', data);

[ls_02] = calllib(lib_name,'get_layer_02', layer_struct, ld_02);

ld_02.reshape(ls_02.n,ls_02.k);

f2 = figure('Units', 'normalized', 'Position', [0.2900 0.0400 0.2900 0.4200]);
hold on
box on
grid on
b1 = bar([0:1:ls_02.k-1], ld_02.Value, 'FaceColor', 'b');

%%
ld_05 = libpointer('singlePtr', data);

[ls_05] = calllib(lib_name,'get_layer_05', layer_struct, ld_05);

ld_05.reshape(ls_05.n,ls_05.k);

f3 = figure('Units', 'normalized', 'Position', [0.0000 0.0400 0.2900 0.4200]);
hold on
box on
grid on
b1 = bar([0:1:ls_05.k-1], ld_05.Value, 'FaceColor', 'b');


%% Layer 12
ld_12 = libpointer('singlePtr', data);

[ls_12] = calllib(lib_name,'get_layer_12', layer_struct, ld_12);
ld_12.reshape(ls_12.n,ls_12.size);

padding = 4;
map_length = 1000;
cell_dim = [7,19];

[layer_img_12] = build_layer_image(ls_12, ld_12, cell_dim, padding, map_length);

f4 = figure('Units', 'normalized', 'Position', [0.1000 0.5000 0.3400 0.4200]);
image(layer_img_12)
axis off
ax = gca;
ax.Position = [0 0 1 1];


%% Layer 9
ld_09 = libpointer('singlePtr', data);

[ls_09] = calllib(lib_name,'get_layer_09', layer_struct, ld_09);
ld_09.reshape(ls_09.n,ls_09.size);

padding = 4;
map_length = 1000;
cell_dim = [6,19];

[layer_img_09] = build_layer_image(ls_09, ld_09, cell_dim, padding, map_length);

f5 = figure('Units', 'normalized', 'Position', [0.4400 0.5000 0.2800 0.4200]);
image(layer_img_09)
axis off
ax = gca;
ax.Position = [0 0 1 1];

%% Layer 5
ld_08 = libpointer('singlePtr', data);

[ls_08] = calllib(lib_name,'get_layer_08', layer_struct, ld_08);
ld_08.reshape(ls_08.n,ls_08.size);

padding = 2;
map_length = 1000;
cell_dim = [6,19];

[layer_img_08] = build_layer_image(ls_08, ld_08, cell_dim, padding, map_length);

f6 = figure('Units', 'normalized', 'Position', [0.7200 0.5000 0.2800 0.4200]);
image(layer_img_08)
axis off
ax = gca;
ax.Position = [0 0 1 1];







