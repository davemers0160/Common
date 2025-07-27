format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%%

% square meters
rcs = 10;
fprintf('Desired RCS: %fm^2\n', rcs)

% frequency (hz)
freq = 9e9;
fprintf('Frequency (GHz): %f\n', freq/1e9)

% wavelength
lambda = physconst('LightSpeed')/freq;

% square trihedral length
a = (rcs * lambda * lambda) / (12 * pi());
length = nthroot(a, 4);

fprintf('Square Trihedral Length: %fm\n', length)

%%

% triangle trihedral length
a = (rcs * lambda * lambda) / (4 * pi());
length = nthroot(a, 4);

L2 = sqrt(2) * length;

fprintf('Triangular Trihedral Lengths: %fm, %fm\n', length, L2)
