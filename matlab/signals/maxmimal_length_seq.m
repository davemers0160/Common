% function SR = maxmimal_length_seq(reg_length)
%
%	input: reg_length => number of elements to use to generate the shift register
%						to generate the Maximal Length Sequence
%	output: SR => The final sequence condition to range between +1 and -1
%
function SR = maxmimal_length_seq(reg_length)

    taps = [1,reg_length];
    
    % initialize register
    register = zeros(1,reg_length);
    register(1) = 1;
    
    sr_size = (2^reg_length)-1;
    SR = zeros(1,sr_size);


    for idx=1:sr_size

        SR(idx) = register(end);
        temp = mod(register(taps(1))+register(taps(2)),2);
    
        register(2:end) = register(1:end-1);
        register(1) = temp;
    end

    % turn shift register into a sequence of +/-1's
    SR = 2*SR-1;
end