function map = jet2(t_min, t_max, t_step)

    t = t_min:t_step:t_max;
    
    t_range = t_max - t_min;
    
    p1 = t_min + t_range * (1 / 4);
    p2 = t_min + t_range * (2 / 4);
    p3 = t_min + t_range * (3 / 4);

    g = max(min(2.0-(1.0)/(p1-t_min)*abs(t - p2),1),0);
    r = max(min((1.0/(p3-p2))*((t-p2)),1),0);
    b = max(min((1.0/(p1-p2))*(t-p2),1),0);

    map = [r',g',b'];
end

% function t = jet_clamp(v)
%     t = min(max(v,0),1);
% end
