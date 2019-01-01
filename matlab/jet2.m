function map = jet2(t_min, t_max, t_step)

    t = t_min:t_step:t_max;
    
    t_range = t_max - t_min;
    t_avg = (t_max + t_min) / 2.0;
    t_m = (t_max - t_avg) / 2.0;

    r = jet_clamp(1.5 - abs((4.0 / t_range)*(t - t_avg - t_m)));
    g = jet_clamp(1.5 - abs((4.0 / t_range)*(t - t_avg)));
    b = jet_clamp(1.5 - abs((4.0 / t_range)*(t - t_avg + t_m)));

    map = [r',g',b'];
end

function t = jet_clamp(v)
    t = min(max(v,0),1);
end
