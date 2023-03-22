function save_image_tiles(base_filename, imgs)

    num_tiles = numel(imgs);

    % create the csv log file for the times: filename, x, y, w, h
    log_filename = strcat(base_filename, '_tile_log.txt');       %'dfd_rw_',num2str(idx),'_',num2str(jdx),'_test_input_v2.txt');
    file_id = fopen(log_filename, 'w');

    fprintf(file_id, '# Log file for image tile save: filename, x, y, w, h\n');
    
    for idx=1:num_tiles
        
        save_filename = strcat(base_filename, num2str((idx-1), '_%04d'), '.png');
        
        imwrite(imgs{idx}.img, save_filename);
    
        fprintf(file_id, '%s, %d, %d, %d, %d\n', save_filename, imgs{idx}.rect(1), imgs{idx}.rect(2), imgs{idx}.rect(3), imgs{idx}.rect(4));
    
    end

    fclose(file_id);
end