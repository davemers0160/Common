

t_min = -1.0;
t_max = 1.0;

t = t_min:0.05:t_max;

t_range = t_max - t_min;
t_avg = (t_max + t_min)/2.0;

t_m = (t_max-t_avg)/2.0;


g = 1.5-abs((4/t_range)*(t-t_avg));
g(g<=0)=0;
g(g>=1)=1;

r = 1.5-abs((4/t_range)*(t-t_avg-t_m));
r(r>=1)=1;
r(r<=0)=0;

b = 1.5-abs((4/t_range)*(t-t_avg+t_m));
b(b>=1)=1;
b(b<=0)=0;
%%
figure(1)
hold on
plot(t,g,'g')
plot(t,r,'r')
plot(t,b,'b')


