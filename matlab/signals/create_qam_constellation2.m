function qam = create_qam_constellation2(k)

    M = 2.^k; % Modulation order
    
    d = 0:M-1;
    [qam] = qammod(d,M,'bin');
    
    for idx=1:numel(qam)
        fprintf('%d, %f, %fi\n',idx-1, real(qam(idx)), imag(qam(idx)));
    end

end

