format long g
format compact
clc
close all
clearvars

%% setup the library paths

lib_path = 'D:\Projects\passive_range\simplex_noise\build\Release\';
lib_name = 'sn_lib';
hfile = 'D:\Projects\passive_range\simplex_noise\include\sn_lib.h';

if(~libisloaded(lib_name))
    [notfound, warnings] = loadlibrary(fullfile(lib_path, strcat(lib_name,'.dll')), hfile);
end

if(~libisloaded(lib_name))
   fprintf('\nThe %s library did not load correctly!',  lib_name);    
end

% libfunctions(lib_name)
% libfunctionsview(lib_name)

%% try to run some of the functions
seed = 10000;
calllib('sn_lib','init', seed);

scale = 1/10;
octaves = 10;
persistence = 70/100;

img_w = 450;
img_h = 450;

octave_image = zeros(img_h,img_w,3);

color = [35,44,41; 61,91,57; 113,114,80;  132,126,64];


for r=1:img_h
    for c=1:img_w
        index = calllib(lib_name, 'octave_evaluate', r, c, scale, octaves, persistence);
        octave_image(r,c,:) = color(index+1, :);
    end
end


image(uint8(octave_image));
%colormap(gray(4));

bp = 1;

%% finish up

%unloadlibrary(lib_name);
