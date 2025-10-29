
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%%

sos = [1.42278e-05, 2.84557e-05, 1.42278e-05, 1, -2.00209, 1.00215;
       1.42572e-05, 2.85144e-05, 1.42572e-05, 1, -2.00623, 1.00628;
       1.42831e-05, 2.85662e-05, 1.42831e-05, 1, -2.00987, 1.00992;
       1.43033e-05, 2.86066e-05, 1.43033e-05, 1, -2.01271, 1.01277;
       1.43161e-05, 2.86323e-05, 1.43161e-05, 1, -2.01452, 1.01457;
       0.00375582, 0.00375582, 0, 1, 0.992488, 0];
   
   
sos2 = [1,2,1,1,-1.99549033451914,0.995717238964040;
        1,2,1,1,-1.98732386604838,0.987549841895454;
        1,2,1,1,-1.98021855835320,0.980443726265566;
        1,2,1,1,-1.97472261319257,0.974947156168621;
        1,2,1,1,-1.97125201248284,0.971476160821683;
        1,1,0,1,-0.985032920759772,0];
    
G2 = [5.67261112259932e-05;5.64939617683977e-05;5.62919780916846e-05;5.61357440117291e-05;5.60370847105660e-05;0.00748353962011390;1];

g2_prod = prod(G2);
   
%%

sample_rate = 1000000;
symbol_length = 1/2400;
amplitude = 2046;   

bits = 147;
data = randi([0,1], bits, 1);
   
%%   
[iqc] = generate_8psk(data, amplitude, sample_rate, symbol_length); 

 %% FFT
Y = fft(iqc)/numel(iqc);
f = linspace(-sample_rate/2, sample_rate/2, numel(Y));

%%
iqc_filt = sosfilt(sos2, iqc);
iqc_filt = iqc_filt*g2_prod;

Y_filt = fft(iqc_filt)/numel(iqc_filt);

%%
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
hold on
plot(f*1e-6, 20*log10(abs(fftshift(Y_filt))), 'r');

xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1; 
   
   
   
   
   
   