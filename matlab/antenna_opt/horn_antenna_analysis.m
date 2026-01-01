function [full_pattern, elevation, azimuth, pat_max, freq_max] = horn_antenna_analysis(freq_range, antenna_object)
    elevation = -10:2:10;
    azimuth = 262:2:278;

    full_pattern = cell(numel(freq_range), 1);
    legend_str = cell(numel(freq_range), 1);
    pat_max = zeros(numel(freq_range), numel(azimuth));
    
    % az_max = zeros(numel(freq_range), 1);
    freq_max = zeros(numel(freq_range), 1);


    for idx=1:numel(freq_range)
        tic;
        fprintf('Freq: %f GHz\n', freq_range(idx)/1e9);
        legend_str{idx, 1} = strcat(num2str(freq_range(idx)/1e9, '%4.3f'), 32, 'GHz').';
    
        % full_pattern{idx, 1} = patternAzimuth(antenna_object,freq_range(idx), elevation, 'Azimuth', azimuth);
        [full_pattern{idx, 1}, azimuth, elevation] = pattern(antenna_object, freq_range(idx), azimuth, elevation);
        % full_pattern(idx, :) = patternAzimuth(antenna_object,freq_range(idx), elevation, 'Azimuth', azimuth);

        % Find the maximum value and its index
        % [pat_max(idx, 1), index] = max(full_pattern{idx, 1}(:));
        % [pat_max(idx, 1), index] = max(full_pattern(idx, :));
        % az_max(idx) = azimuth(index);
        % Find the maximum value and its linear index
        % [pat_max(idx, 1), index] = max(full_pattern{idx, 1}(:));
        [pm, index] = max(full_pattern{idx, 1}(:));


        
        % Convert the linear index to row and column indices
        % [pat_row(idx), pat_col(idx)] = ind2sub(size(full_pattern{idx, 1}), index);
        [pr, pc] = ind2sub(size(full_pattern{idx, 1}), index);

        pat_max(idx, pc) = pm;
        freq_max(idx) = pm;
        toc
    end

    plot_num = 1;
%%
    figure(plot_num)
    set(gcf,'position',([50,100,1000,800]),'color','w')
    surf(azimuth, freq_range/1e9, pat_max)
    grid on
    box on
    set(gca,'fontweight','bold','FontSize', 13);
    ylim([freq_range(1)/1e9, freq_range(end)/1e9]);
    zlim([1, ceil(max(pat_max(:)))]);

    ylabel('Frequency (GHz)', 'fontweight', 'bold', 'FontSize', 13);
    xlabel('Azimuth (deg)', 'fontweight', 'bold', 'FontSize', 13);
    plot_num = plot_num + 1;

    figure(plot_num)
    set(gcf,'position',([50,100,1000,800]),'color','w')
    plot(freq_range/1e9, freq_max, '-b');
    grid on
    box on
    set(gca,'fontweight','bold','FontSize', 13);
    xlim([freq_range(1)/1e9, freq_range(end)/1e9]);
    ylim([1, ceil(max(pat_max(:)))]);
    
    xlabel('Frequency (GHz)', 'fontweight', 'bold', 'FontSize', 13);
    ylabel('Azimuth (deg)', 'fontweight', 'bold', 'FontSize', 13);
    plot_num = plot_num + 1;

end
