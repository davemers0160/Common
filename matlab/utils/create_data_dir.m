function create_data_dir(scenario_name, save_location)
    % save_location = 'D:\IUPUI\Test_Data\real_world_raw\';
    
    fprintf('Creating scenario directory: %s\n', fullfile(save_location, scenario_name))
    mkdir(fullfile(save_location, scenario_name));

    fprintf('Creating: %s\n',fullfile(save_location, scenario_name, 'left'));
    mkdir(fullfile(save_location, scenario_name, 'left'));
    fprintf('Creating: %s\n',fullfile(save_location, scenario_name, 'right'));
    mkdir(fullfile(save_location, scenario_name, 'right'));
    fprintf('Creating: %s\n',fullfile(save_location, scenario_name, 'lidar'));
    mkdir(fullfile(save_location, scenario_name, 'lidar'));
    fprintf('Complete\n');
    
end

