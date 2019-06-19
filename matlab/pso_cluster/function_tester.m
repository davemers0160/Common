
%%
N = 20;
z = rand(6,784);

d = cell(size(z,1),N);
m_idx = zeros(size(z,1),N);

x = cell(N,1);

for idx=1:N
    x{idx,1} = rand(6,784);
end

itr = 1;
for jdx=1:N
    for idx=1:size(z,1)

        [d{idx,jdx},m_idx(idx,jdx)] = calc_distance(z(idx,:), x{jdx,1});

    end
    
    F(jdx, itr) = calc_fitness(d(:,jdx), m_idx(:,jdx));
end

