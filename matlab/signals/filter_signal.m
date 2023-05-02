function [x1] = filter_signal(iq, fs, fc, fo, n_taps)

    plot_num = 1;
    close all

    % calculate the x axis
    x = linspace(-fs/2, fs/2, numel(iq));

    % create window
    w = nuttall_window(n_taps);

    % create the full filter using the window
    lpf = create_fir_filter(fc, w);
    fft_lpf = fft(lpf)/numel(lpf);
    x_lpf = linspace(-fs/2, fs/2, numel(fft_lpf));


    % create a frequency shift vector for the filter
    fc_rot = exp(1.0j*-2.0*pi()* fo/fs*(0:(numel(lpf)-1))).';
    lpf_r = lpf.' .* fc_rot;
    fft_lpf_r = fft(lpf_r)/numel(lpf_r);


    figure(plot_num)
    set(gcf,'position',([50,50,1400,500]),'color','w')
    hold on;
    plot(0:n_taps-1, lpf,'k')
    grid on
    box on
    set(gca,'fontweight','bold','FontSize', 13);
    xlim([0, n_taps-1]);
    title('Plot of Filter', 'fontweight', 'bold', 'FontSize', 14);
    
    plot_num = plot_num + 1;

    figure(plot_num)
    set(gcf,'position',([50,50,1400,500]),'color','w')
    hold on;
    plot(x_lpf/1e6, 20*log10(abs(fftshift(fft_lpf))),'k')
    plot(x_lpf/1e6, 20*log10(abs(fftshift(fft_lpf_r))),'g')
    grid on
    box on
    set(gca,'fontweight','bold','FontSize', 13);
    xlim([x_lpf(1), x_lpf(end)]/1e6);
    xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
    ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
    title('Frequency Response of LPF Filter', 'fontweight', 'bold', 'FontSize', 14);

    plot_num = plot_num + 1;


    % apply the filter to the signal
    x1 = conv(iq, lpf_r(end:-1:1), 'same');

    fft_x0 = fft(iq)/numel(iq);
    fft_x1 = fft((2^11)*x1)/numel(x1);

    figure(plot_num)
    set(gcf,'position',([50,50,1400,500]),'color','w')
    hold on;
    plot(x/1e6, 20*log10(abs(fftshift(fft_x0))),'k')
    plot(x/1e6, 20*log10(abs(fftshift(fft_x1))),'g')
    grid on
    box on
    set(gca,'fontweight','bold','FontSize', 13);
    xlim([x(1), x(end)]/1e6);
    xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
    ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
    title('Filtered vs. Un-Filtered Signal', 'fontweight', 'bold', 'FontSize', 14);
    
    plot_num = plot_num + 1;


end
