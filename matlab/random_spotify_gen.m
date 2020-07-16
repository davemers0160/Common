format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%%

bars = [18, 28, 40, 52, 64, 74, 86, 96];


% number of lines
N = 21;

% first and last segment are the smallest.  The other 21 are 1 of 6
% different sizes

% width of the line
w = 10;

% base segment length
s = 10;

% padding between lines
p = 10;

logo = double(rgb2gray(imread('C:\Users\owner\Pictures\sptofiy_symbol2.png')));

%%

code = randi([1 8], 1, N);
code = [1, code, 1];
code(12) = 8;

%code = [1, 6, 1, 3, 4, 5, 2, 5, 6, 3, 4, 8, 4, 8, 2, 6, 7, 3, 6, 8, 5, 4, 1];
 code = [1, 1, 8, 6, 4, 2, 2, 6, 3, 1, 2, 8, 5, 5, 7, 5, 4, 5, 1, 5, 8, 2, 1];


base = 255*ones(s*8*2, w);
pad = 255*ones(s*8*2, w);

img = [pad];
h = floor(size(base, 1)/2);

for idx=1:numel(code)
    
    segment = base;
    
    c = code(idx);
       
    segment(h-floor(bars(c)/2):h+floor(bars(c)/2)-1, :) = zeros(bars(c), w); 
    
    img = cat(2, img, segment, pad);
end

img = cat(2, img, pad, pad, pad);


%SE = strel('square', 3);
SE1 = strel('diamond',3);
SE2 = strel('diamond',1);
SE3 = [1 0 0 0 1; 0 1 0  1 0; 0 0 1 0 0; 0 1 0  1 0; 1 0 0 0 1];

img = imerode(img, SE2);
%img = imerode(img, SE1);

img = imdilate(img, SE3);
%img = imdilate(img, SE2);
img = imerode(img, SE2);
img = imerode(img, SE2);

%%
img = cat(2, logo, img);


figure
set(gcf,'position',([100,100,1000,300]),'color','k')
imshow(uint8(img))
colormap(gray(2))
axis off

imwrite(uint8(img), 'd:/Projects/test.png');
