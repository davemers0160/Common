function create_movie(filename, data, fps)

    wb = waitbar(0,'Building Movie...');
    % create the video write object and set the properties
    v = VideoWriter(filename, 'MPEG-4');
    v.Quality = 100;
    %v.LosslessCompression = 'true';
    v.FrameRate = fps;
    
    % open the video writer
    open(v);

    % write the data to the video object
    for idx=1:length(data)
        writeVideo(v, data{idx})
        waitbar(idx/length(data), wb);
    end
    waitbar(100,wb, 'Operations complete!');
    
    % close the object
    close(v);
    
    pause(1);
    delete(wb);    
end