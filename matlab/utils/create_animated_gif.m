function create_animated_gif(filename, delay, data, loop_count)
    % filename: name of file 
    % delay: vector for the delay
    frame_count = length(data);
    
    wb = waitbar(0,'Building Animated GIF...');
    for idx = 1:frame_count
        
        if(size(data{idx},3)==3)
            [A,map] = rgb2ind(data{idx},256);
        else
            [A,map] = gray2ind(data{idx},256);            
        end
        
        if idx == 1
            imwrite(A,map,filename,'gif','LoopCount',loop_count,'DelayTime',delay(idx));
        else
            imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',delay(idx));
        end
        
        waitbar(idx/frame_count,wb);
    end

    waitbar(100,wb, 'Operations complete!');
    pause(1);
    delete(wb);
end