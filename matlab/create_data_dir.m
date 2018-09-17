function create_data_dir(scenario_name)
    save_path = 'D:\IUPUI\Test_Data\Real_World\';
    
    fprintf('Creating scenario directory: %s\n', fullfile(save_path, scenario_name))
    mkdir(fullfile(save_path, scenario_name));

    fprintf('Creating: %s\n',fullfile(save_path, scenario_name, 'left'));
    mkdir(fullfile(save_path, scenario_name, 'left'));
    fprintf('Creating: %s\n',fullfile(save_path, scenario_name, 'right'));
    mkdir(fullfile(save_path, scenario_name, 'right'));
    fprintf('Creating: %s\n',fullfile(save_path, scenario_name, 'lidar'));
    mkdir(fullfile(save_path, scenario_name, 'lidar'));
    fprintf('Complete\n');
    
end

