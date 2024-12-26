
% row 0:  0  1  2  3  4  5  6  7
% row 1: 15 14 13 12 11 10  9  8
% row 2: 16 17 18 19 20 21 22 23
% row 3: 31 30 29 28 27 26 25 24

%%

M=64;
x = (0:M-1)';
[y,mapy] = bin2gray(x,'qam',M);

m = bitshift(M, -3);

b = log(M)/log(2);

%%

% return n ^ (n >> 1);

gc = zeros(M,1);
for idx=0:M-1

    gc(idx+1,1) = bitxor(idx, bitshift(idx, -1)); 
    
end

%%
index = 0;

map_iq = zeros(M,1);

figure
hold on

for r = 0:m-1
    for c = 0:m-1
        
        if(mod(r,2) == 0)
            index = c + (m*r);            
        else            
            index = (m*(r+1)-1) - c;
        end
        
%         fprintf('%s\n',dec2base(gc(index+1),2, b));
        
        map_iq(gc(index+1)+1, 1) = complex(-(m-1) + 2*r, -(m-1) + 2*c);
        
        x = real(map_iq(gc(index+1)+1,1));
        y = imag(map_iq(gc(index+1)+1,1));
        text( x-0.25,y-0.3, dec2base(gc(index+1),2, b),'Color',[1 0 0]);
        scatter(x, y, 30, '*', 'k');
    end
end


%%



