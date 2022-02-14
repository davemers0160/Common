% https://noaa-apt.mbernardi.com.ar/how-it-works.html

[data, fs_a] = audioread('D:\Projects\apt-decoder-master\examples\noaa18_202202013_1201.wav');

% bring this back to 16-bit int
d1 = data*32768;
fc = 2400;
fb = 4160;

n = numel(d1);

figure;
spectrogram(d1, 8192, 4096, 8192, fs_a, 'centered')

%%
d2 = zeros(n,1);

for idx=2:n
    
    d2(idx) = sqrt( d1(idx)*d1(idx) +  d1(idx-1)*d1(idx-1) - 2*d1(idx)*d1(idx-1)*cos(2*pi()*fc/fs_a) )/sin(2*pi()*fc/fs_a);
    
end

%%
win_size = 256;
lpf = fir1(win_size, fb/fs_a, 'low', nuttallwin(win_size+1,'periodic'));

d3 = filter(lpf, 1, d2);

d4 = d3(2:5:end);

%% digitize

x = prctile(d4, [0.4, 99.75]);

min_val = min(x);
max_val = max(x);

delta = max_val - min_val;

% Normalize the signal to px luminance values, discretize
d5 = floor((255 * (d4 - min_val) / delta) + 0.5);
d5(d5 < 0) = 0;
d5(d5 > 255) = 255;

%% correlations

d5s = d5 - 128;
% sync = [0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 0 0] - 128;
sync = 2*[0 0 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 0 0 0 0 0 0] - 1;

% c5 = conv(d5s, sync(end:-1:1), 'same')/39;
% 
% c5 = c5(20:end);

mindistance = 2000;

peaks = [1,0];


for idx=1:numel(d5s)-numel(sync)

    c5d(idx) = dot(sync, d5s(idx:idx+numel(sync)-1))/numel(sync);

    corr = c5d(idx);

    % If previous peak is too far, we keep it but add this value as new
    if ((idx - peaks(end,1)) > mindistance)
        peaks(end+1,:) = [idx, corr];
    elseif (corr > peaks(end,2))
        peaks(end,:) = [idx, corr];
    end

end


%%

img = [];

for idx=1:(size(peaks,1) - 1)

    img = cat(1,img, d5(peaks(idx,1):peaks(idx,1)+2079)');

%     matrix.append(signal[peaks[i][0] : peaks[i][0] + 2080])

end


figure
image(uint8(img));
colormap(gray(256));







%% try to clip 
% x2 = prctile(c5, 99.9);
% x2 = max(c5)*0.6;
% 
% c5s = c5;
% c5s(c5s < x2) = 0;
% c5s(c5s >= x2) = 255;
% 
% %%
% figure
% plot(d5)
% hold on
% plot(c5)
% plot(c5s)
% plot([1 numel(c5)], [x2, x2], 'k')


%%



%% telemtry
% t_a = img(:, 997:997+41);
wedge_a_center = 1017;
wedge_offset = 31;

wedge_a_x0 = 997;
wedge_a_x1 = 1036;
wedge_y = 8;

t_a = img(:, wedge_a_center);

% w = [31:32:255];
% w = repelem(w,8);
w = repelem([255, 0],8);

t_w = conv(t_a, w(end:-1:1), 'same');

threshold = prctile(t_w, 99.5);

% get first max
[~, max_telem] = max(t_w);

if(max_telem > wedge_y)
    
    wedge_8 = img((max_telem-wedge_y+1):(max_telem), wedge_a_x0:wedge_a_x1);
    wedge_9 = img((max_telem+1):(max_telem+wedge_y), wedge_a_x0:wedge_a_x1);
    
    mean_8 = mean(wedge_8(:));
    mean_9 = mean(wedge_9(:));
end

img = 255*(img-mean_9)/(mean_8-mean_9);

img(img>255) = 255;
img(img<0) = 0;


figure
image(uint8(img));
colormap(gray(256));





