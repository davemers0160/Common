
% row 0:  0  1  2  3  4  5  6  7
% row 1: 15 14 13 12 11 10  9  8
% row 2: 16 17 18 19 20 21 22 23
% row 3: 31 30 29 28 27 26 25 24

format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;

%%


num_bits = 6;

M = bitshift(1, num_bits);

side_length = bitshift(M, -3);

x = (0:M-1)';
[y,mapy] = bin2gray(x, 'qam', M);

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

for r = 0:side_length-1
    for c = 0:side_length-1
        
        if(mod(r,2) == 0)
            index = c + (side_length*r);            
        else            
            index = (side_length*(r+1)-1) - c;
        end
        
%         fprintf('%s\n',dec2base(gc(index+1),2, b));
        
        map_iq(gc(index+1)+1, 1) = complex(-(side_length-1) + 2*r, -(side_length-1) + 2*c);
        
        x = real(map_iq(gc(index+1)+1,1));
        y = imag(map_iq(gc(index+1)+1,1));
        text( y-0.3,x-0.3, strcat(dec2base(gc(index+1),2, num_bits), 32,'(', num2str(gc(index+1),"%02d"),')'),'Color',[1 0 0]);
        text( y-0.3,x-0.6, strcat('(', num2str(-(side_length-1) + 2*c),',',num2str(-(side_length-1) + 2*r),')'),'Color',[0 0 0]);
        scatter(y, x, 30, '*', 'k');
    end
end


%%



