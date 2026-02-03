function x = calculate_worst_case_symbols(h, samples_per_symbol)
    
    x = [];

    end_index = floor(numel(h)/samples_per_symbol)*samples_per_symbol;



    for idx = 1:samples_per_symbol:end_index

        block = h(idx:idx+samples_per_symbol);

        block_sum = sum(block);

        if(block_sum >= 0)
            n = 1;
        else
            n = -1;
        end

        x = cat(1, x, n*ones(samples_per_symbol,1)); 

    end


end