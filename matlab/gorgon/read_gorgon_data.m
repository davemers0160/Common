function [gorgon_data, gorgon_struct] = read_gorgon_data(filename)

    gorgon_xml_struct = xml2struct(filename);

    if(~isfield(gorgon_xml_struct,'gorgon_data'))
        return;
    end

    version = strcat(gorgon_xml_struct.gorgon_data.version.Attributes.major, '.', gorgon_xml_struct.gorgon_data.version.Attributes.minor);
    layer_number = str2double(gorgon_xml_struct.gorgon_data.layer.Attributes.number);

    nc = str2double(gorgon_xml_struct.gorgon_data.filter.Attributes.cols);
    nr = str2double(gorgon_xml_struct.gorgon_data.filter.Attributes.rows);
    n = str2double(gorgon_xml_struct.gorgon_data.filter.Attributes.n);
    k = str2double(gorgon_xml_struct.gorgon_data.filter.Attributes.k);

    data_size = n*nr*nc*k;

    
    %% get the data file and read it in

    [file_path, datafile_name, ~] = fileparts(filename);

    datafile_name=strcat(file_path,'\',datafile_name,'.dat');
    tmp=dir(datafile_name);
    file_size=tmp.bytes;

    fileID = fopen(datafile_name, 'r','l');

    magic_number = fread(fileID,1,'uint32');

    step = [];
    gorgon_data = {};

    index=1;
    while ~feof(fileID)

        g.step = fread(fileID,1,'uint64');
        position = ftell(fileID);

        if((file_size-position)>=data_size*4)
            for idx=1:n*k
                g.data(:,:,idx) = reshape(fread(fileID,nr*nc,'float32'),nc,nr)';
            end
            gorgon_data{index,1} = g;
            index = index + 1;
        else
            fseek(fileID, 0,'eof');
            break;
        end

    end
    fclose(fileID);

    k = numel(gorgon_data);
    
    gorgon_struct = struct();
    gorgon_struct.n = n;
    gorgon_struct.k = k;
    gorgon_struct.nr = nr;
    gorgon_struct.nc = nc;
    gorgon_struct.version = version;
    gorgon_struct.layer = layer_number;

    
end