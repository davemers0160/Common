function get_bb_stats(gt_table, index)
    
    data = gt_table.Variables;
    label_names = gt_table.Properties.VariableNames;
    
    num_images = size(data,1);
    num_classes = size(data,2);
    
    h = [];
    w = [];
    for idx=1:num_images
                
        if(~isempty(data{idx,index}))
            
            num_boxes = size(data{idx,index},1);
            
            for kdx = 1:num_boxes
                w(end+1) = ceil(data{idx,index}(kdx,3));
                h(end+1) = ceil(data{idx,index}(kdx,4));
                %img = insertObjectAnnotation(img,'rectangle',data{idx,index}(kdx,:), label_names{index}, 'Color',floor(255*cm(index,:)), 'TextBoxOpacity',0.9,'FontSize',9, 'TextColor','black');
               
            end           
        end        
    end
      
    fprintf('min/max width: %d/%d\n', min(w), max(w));
    fprintf('min/max height: %d/%d\n', min(h), max(h));
    fprintf('Number of occurences: %d\n', numel(w));
    
end
