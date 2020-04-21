function listing = get_listing(data_path, file_type)
    
    listing = dir(strcat(data_path, filesep, file_type));
    
end
