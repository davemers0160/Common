format long g;
format compact;
close all;
%clearvars;
clc;

plot_count = 1;
% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);


% sample rate
sample_rate = 30e6;

% number of points for the fft
fftN = 30;
range = [fftN/2+1:fftN,1:fftN/2];
freq_sp = sample_rate/fftN;
fftTimeStep = fftN/sample_rate;

% IQ file duration
num_seconds = 400e-6/3;
num_samples = num_seconds * sample_rate;

% RF offset from tuned center frequency
Fo = 0;
time_step = (0:1/sample_rate:(num_seconds - 1/sample_rate))';
time_samples = length(time_step);

%% Chirp Data
f0 = 1e6;
f1 = 5e6;
chirp_width = f1 - f0;
k = chirp_width/num_seconds;
phi = 0;	%-chirp_width/2;

I = 0.9*(cos(phi + 2*pi*(f0*time_step + (k/2)*time_step.^2)));
Q = 0.9*(sin(phi + 2*pi*(f0*time_step + (k/2)*time_step.^2)));

signal = complex(I,Q);
IQ_length = length(signal);

%% Plot the generated IQ data
figure(plot_count)
set(gcf,'position',([100,100,800,600]),'color','w')
plot(real(signal),'b')
hold on
plot(imag(signal),'r')
title('I and Q signal data')
legend('I','Q')
plot_count = plot_count + 1;



captures = floor(IQ_length/fftN);
time_frame = (0:fftTimeStep:fftTimeStep*(captures-1));

Y = zeros(fftN,captures);
for idx=0:captures-1
    %w = [w,fft(IQ(:,idx))/N];
    Y(:,idx+1) = fft(signal((idx*fftN)+1:(idx+1)*fftN))/fftN;
    %Y_n(:,idx+1) = fft(IQ_noise((idx*N)+1:(idx+1)*N))/N;
    %Y2(:,idx+1) = fft(tmp_noise((idx*N)+1:(idx+1)*N))/N;
end

% for plotting purposes only
%Fc = 315e6;

%% plot the sepctragram of the generated IQ data
f = linspace(-0.5 * sample_rate, 0.5 * sample_rate, fftN);
figure(plot_count)
set(gcf,'position',([100,100,1000,600]),'color','w')
surf(time_frame,f,2*abs((Y)))
shading interp
view(90,90)
plot_count = plot_count + 1;

% figure(plot_count)
% S = spectrogram(signal,fftN,0);
% surf(time_frame,f,2*abs((S)))
% plot_count = plot_count + 1;




%% filter the data around Fo
fpass = 10e6;
Fp = fpass/sample_rate;

Hiirlp = design(fdesign.lowpass(Fp,.75,.75,80),'ellip');
Fc  = Fo/sample_rate;                         % Desired frequency shift
Hiircbp = ciirxform(Hiirlp, ...   % Shift frequency transformation
    'zpkshiftc', 0, Fc);          % DC shifted to Fc

data_filt = filter(Hiircbp,signal);

%% Plot the raw IQ data and the filtered IQ data 
f = linspace(-0.5 * sample_rate, 0.5 * sample_rate, length(signal));
figure(plot_count)
set(gcf,'position',([100,100,800,600]),'color','w')
plot(f, 20*log10(abs(fftshift(fft(signal)))/num_samples),'b');
hold on
plot(f, 20*log10(abs(fftshift(fft(data_filt)))/num_samples),'r');
title('FFT of Signals')
legend('Raw Signal','Filtered Signal');
plot_count = plot_count + 1;

% figure(plot_count)
% plot(real(data_filt),'b')
% hold on
% plot(imag(data_filt),'r')
% plot_count = plot_count + 1;


%% Plot the auto correlation
auto_corr = conv(signal(1:end),conj(signal(end:-1:1)));
%signal_corr = conv(signal(1:end),signal(end:-1:1));
filtered_auto_corr = conv(data_filt(1:end),signal(end:-1:1));

figure(plot_count)
set(gcf,'position',([100,100,800,600]),'color','w')
plot(abs(auto_corr),'.-g')
hold on
%plot(abs(filtered_auto_corr),'.-r')
title('Convolution Autocorrelation')
legend('Auto Correlation');
plot_count = plot_count + 1;


%% Save the resulting signals to a file
% err = save_sc16q11( strcat(startpath,'\IQ_Test_Files\chirp_test_raw_30MSPS.sc16q11'), signal); 
% save_csv( strcat(startpath,'\IQ_Test_Files\chirp_test_raw30MSPS.csv'), signal); 
% 
% err = save_sc16q11( strcat(startpath,'\IQ_Test_Files\chirp_test_filter30MSPS.sc16q11'), data_filt*(0.9));
% save_csv( strcat(startpath,'\IQ_Test_Files\chirp_test_filter.csv'), data_filt*(0.9)); 