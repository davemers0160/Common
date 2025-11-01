format long g
format compact
% clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%%

% sos = [1.42278e-05, 2.84557e-05, 1.42278e-05, 1, -2.00209, 1.00215;
%        1.42572e-05, 2.85144e-05, 1.42572e-05, 1, -2.00623, 1.00628;
%        1.42831e-05, 2.85662e-05, 1.42831e-05, 1, -2.00987, 1.00992;
%        1.43033e-05, 2.86066e-05, 1.43033e-05, 1, -2.01271, 1.01277;
%        1.43161e-05, 2.86323e-05, 1.43161e-05, 1, -2.01452, 1.01457;
%        0.00375582, 0.00375582, 0, 1, 0.992488, 0];
   
% 11 order, fc=2400/960000
sos2a = [
0.0000583530,	0.0001167060,	0.0000583530,	1.0000000000,	-1.9956600000,	0.9959080000;
0.0000581232,	0.0001162460,	0.0000581232,	1.0000000000,	-1.9878000000,	0.9880490000;
0.0000579188,	0.0001158380,	0.0000579188,	1.0000000000,	-1.9808100000,	0.9810560000;
0.0000577529,	0.0001155060,	0.0000577529,	1.0000000000,	-1.9751400000,	0.9753820000;
0.0000576362,	0.0001152720,	0.0000576362,	1.0000000000,	-1.9711500000,	0.9713900000;
0.0000575760,	0.0001151520,	0.0000575760,	1.0000000000,	-1.9690900000,	0.9693300000;];
    


% 1,2,1,1,-1.99566172672458,0.995907956936059;
%          1,2,1,1,-1.98780470979604,0.988049970587248;
%          1,2,1,1,-1.98081271607830,0.981057114178164;
%          1,2,1,1,-1.97514014950067,0.975383847703727;
%          1,2,1,1,-1.97114860885104,0.971391814566880;
%          1,2,1,1,-1.96908876566162,0.969331717228359];

    %0.00779293629195155
g2a = [6.15575528702666e-05;6.13151978015172e-05;6.10995249661940e-05;6.09245507647367e-05;6.08014289594313e-05;6.07378916853836e-05];

g2a_prod = prod(g2a);
   
%%

sample_rate = 960000;
symbol_length = 1/2400;
amplitude = 2046;
order = 12;

bits = 100;
data = randi([0,1], bits, 1);

data = [ 0 0 1 0 0 1 0 0 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 0 0 1 0 0 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1];
% data = cat(2, data, randi([0,1], 1, bits));
   
%%   
[iqc] = generate_8psk(data, amplitude, sample_rate, symbol_length); 

% max(abs(real(iqc)))
% max(abs(imag(iqc)))

 %% FFT
Y = fft(iqc)/numel(iqc);
f = linspace(-sample_rate/2, sample_rate/2, numel(Y));

%%
% sos2_m = sos2;
% sos2_m(1, 1:3) = sos2_m(1, 1:3) * g2_prod;
% sos2_m(:,1:3) = sos2_m(:,1:3).*G2;

[zhi,phi,khi] = butter(order, 2*(1/symbol_length)/sample_rate, 'low');
[sos2, g2] = zp2sos(zhi,phi,khi);
sos2_m = sos2a;
sos2_m(1,1:3) = sos2_m(1,1:3).*g2a_prod;

iqc_filt = sosfilt(sos2a, iqc);
% iqc_filt = iqc_filt*g2_prod;

Y_filt = fft(iqc_filt)/numel(iqc_filt);

% max(abs(real(iqc_filt)))
% max(abs(imag(iqc_filt)))

%% 

% [sos_t, G_test] = butterworth_df2t_manual(sample_rate, 1/symbol_length, order);
% [sos_t, G_test] = butterworth_sos(sample_rate, 1/symbol_length, order);
idx = 1.0;
fprintf('order\tgain\n');
% for order=32:2:40
%     for idx=0.98:-0.000001:0.90
        [sos_t, gt] = butterworth_df2t((1/symbol_length)/sample_rate, order, idx);
        gt_prod = prod(gt);

        iqc_filt_t = sosfilt(sos_t, iqc);
        % iqc_filt_t = iqc_filt_t*prod(gt);

        Y_filt_t = fft(iqc_filt_t)/numel(iqc_filt_t);

        m = max(max(abs(real(iqc_filt_t))), max(abs(imag(iqc_filt_t))));
        if(m < 2046)
%             fprintf('max value = %f\n', m);
%             fprintf('gain value = %f\n', idx);
            fprintf('%d, %10.9f, %f\n', order, idx, m);
%             break;
        end

%     end
% end

%%

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
hold on
plot(f*1e-6, 20*log10(abs(fftshift(Y_filt))), 'r');
plot(f*1e-6, 20*log10(abs(fftshift(Y_filt_t))), 'g');

xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1; 
   
%%

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(real(iqc),'b')

box on
grid on
hold on
plot(real(iqc_filt),'r')
plot(real(iqc_filt_t),'g')
plot(imag(iqc),'m')
plot(real(filtered),'c')

xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1; 
   
   
   
   