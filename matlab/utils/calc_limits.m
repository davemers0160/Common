function [ticks, labels] = calc_limits(min_val, max_val, steps, fmt)

    d = abs(max_val - min_val);
    step_val = 1/steps;
    
    step_max = ceil(max_val*steps)/steps;
    
    
    t_start = floor(min_val/step_val) * step_val;
    t_stop = t_start + step_max;
    
    ticks = t_start:step_val:t_stop;
    
    labels = num2str(ticks', fmt);


end