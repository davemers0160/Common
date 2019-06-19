function [x, v, g, p, pso_stats, itr_cnt] = PSO(f, N, itr_max, v_max, x_lim, w, c1, c2, method)

itr_cnt = 0;

phi = c1 + c2;
Kap = 2/(abs(2 - phi - sqrt(phi^2 - 4*phi)));

% sv = symvar(f);
% numvars = numel(sv);
numvars = size(x_lim,1);
x = cell(1,itr_max);
v = cell(1,itr_max);
p = cell(1,itr_max);
g = zeros(numvars,itr_max);

% initialize position vectors
x{1} = x_lim(:,1)+(x_lim(:,2)-x_lim(:,1)).*rand(numvars,N);

% initialize velocity vectors
v{1} = v_max(:,1)+(v_max(:,2)-v_max(:,1)).*rand(numvars,N);
v{1} = limit_check(v{1}, v_max, N);

% copy x into p
p{1} = x{1};
    
% find minimum function value for f{1}
for idx=1:N
    %f_temp(idx) = double(subs(f,sv,x{1}(:,idx)'));
    f_temp(1,idx) = f(x{1}(:,idx)');
end
[f_min, f_min_idx] = min(f_temp(1,:));
g(:,1) =  x{1}(:,f_min_idx);

pso_stats = [];

% figure(1)

while(itr_cnt < itr_max)

    %fprintf('PSO Generation: %03d\n', itr_cnt);
    itr_cnt = itr_cnt +1;

    % generate r and s vectors
    r{itr_cnt} = rand(numvars,N);
    s{itr_cnt} = rand(numvars,N);
    
%     scatter(0.65041978297, -0.65041978297, 'ok', 'filled')
%     hold on
%     scatter(x{itr_cnt}(1,:), x{itr_cnt}(2,:), 'ob', 'filled');
%     scatter(g(1,itr_cnt), g(2,itr_cnt), 'og', 'filled');
%     set(gca, 'xlim', x_lim(1,:), 'ylim', x_lim(2,:));
%     title(strcat('Generation:',32,num2str(itr_cnt)), 'fontweight','bold');
%     hold off
%     drawnow;
    %pause(0.0001);
    
    [f_min, f_min_idx] = min(f_temp(itr_cnt,:));
    [f_max, f_max_idx] = max(f_temp(itr_cnt,:));
    pso_stats(:,itr_cnt) = [f_min; mean(f_temp(itr_cnt,:)); f_max];   
    
    % Step 2 - calculate new velocity and position
    % method 1
    if(strcmp(method,'normal')==1)
        v{itr_cnt+1} = w*v{itr_cnt} + (c1*r{itr_cnt}).*(p{itr_cnt} - x{itr_cnt}) + (c2*s{itr_cnt}).*(g(:,itr_cnt) - x{itr_cnt});
    % method 2
    elseif(strcmp(method,'constrict')==1)
        v{itr_cnt+1} = Kap*(v{itr_cnt} + (c1*r{itr_cnt}).*(p{itr_cnt} - x{itr_cnt}) + (c2*s{itr_cnt}).*(g(:,itr_cnt) - x{itr_cnt}));
    end
       
    v{itr_cnt+1} = limit_check(v{itr_cnt+1}, v_max, N);

    x{itr_cnt+1} = x{itr_cnt} + v{itr_cnt+1};
        
    % x limit check
    x{itr_cnt+1} = limit_check(x{itr_cnt+1}, x_lim, N);
    
    % Step 3
    for idx=1:N
        %f_temp(idx) = double(subs(f,sv,x{itr_cnt+1}(:,idx)'));
        f_temp(itr_cnt+1,idx) = f(x{itr_cnt+1}(:,idx)');
        %if(double(subs(f,sv,x{itr_cnt+1}(:,idx)')) < double(subs(f,sv,p{itr_cnt}(:,idx)')))
        if(f_temp(itr_cnt+1,idx) < f_temp(itr_cnt,idx))
            p{itr_cnt+1}(:,idx) = x{itr_cnt+1}(:,idx);
        else
            p{itr_cnt+1}(:,idx) = p{itr_cnt}(:,idx);
        end
    end
         
    % Step 4 - find an f(x) value that is less than f(g-best)
    
    %g_best = double(subs(f,sv,g(:,itr_cnt)'));
    g_best = f(g(:,itr_cnt)');
    x_idx = find(f_temp(itr_cnt+1,:) < g_best);
    
    if(~isempty(x_idx))
        [f_min, xmin_idx] = min(f_temp(itr_cnt+1, x_idx));
         g(:,itr_cnt+1) = x{itr_cnt+1}(:,x_idx(xmin_idx));
    else
        g(:,itr_cnt+1) = g(:,itr_cnt);
    end       
    
    
%     for idx=1:N
%         if(double(subs(f,sv,x{itr_cnt+1}(:,idx)')) < double(subs(f,sv,g(:,itr_cnt)')))
%             x_idx = idx;
%             %g(:,itr_cnt+1) = x{itr_cnt+1}(:,idx);
%             %break;
%         %else
%             %g(:,itr_cnt+1) = g(:,itr_cnt);
%         end
%     end
%     
%     % fill in the best option into g-best
%     if(x_idx ~= 0)
%         g(:,itr_cnt+1) = x{itr_cnt+1}(:,x_idx);
%     else
%         g(:,itr_cnt+1) = g(:,itr_cnt);
%     end
    

end


end