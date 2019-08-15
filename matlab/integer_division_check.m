
% con
% OUT.nr() == 1+(IN.nr() + 2*padding_y() - nr())/stride_y()


in_nr = 15:200;

padding = 0;

stride = 2;

nr = 3;

con_out_nr1 = 1+floor((in_nr + 2*padding - nr)/stride);
con_out_nr2 = 1+floor((con_out_nr1 + 2*padding - nr)/stride);
con_out_nr3 = 1+floor((con_out_nr2 + 2*padding - nr)/stride);
con_out_nr4 = 1+floor((con_out_nr3 + 2*padding - nr)/stride);

nr_t = 4;
cont_out_nr1 = stride*(con_out_nr4-1) + nr_t - 2*padding;
cont_out_nr2 = stride*(cont_out_nr1-1) + nr_t - 2*padding;
cont_out_nr3 = stride*(cont_out_nr2-1) + nr_t - 2*padding;
cont_out_nr4 = stride*(cont_out_nr3-1) + nr_t - 2*padding;


figure(1)
set(gcf,'position',([100,100,800,600]),'color','w');
grid on
hold on

plot(in_nr, in_nr, '-r')
plot(in_nr, (in_nr-1)/2, '-r')
plot(in_nr, (in_nr-1)/4, '-r')
plot(in_nr, (in_nr-1)/8, '-r')
plot(in_nr, con_out_nr1, '.-g')
plot(in_nr, con_out_nr2, '.-g')
plot(in_nr, con_out_nr3, '.-g')
plot(in_nr, con_out_nr4, '.-g')
plot(in_nr, cont_out_nr1, '.-c')
plot(in_nr, cont_out_nr2, '.-c')
plot(in_nr, cont_out_nr3, '.-c')
plot(in_nr, cont_out_nr4, '.-c')
set(gca,'fontweight','bold');
xlabel('Input Row Pixel Size','fontweight','bold');
ylabel('Output Row Pixel Size','fontweight','bold');
%legend(strcat('con',num2str(nr),'d'),strcat('con',num2str(nr),'d->con',num2str(nr),'d'),'location','southeast','Orientation','vertical')


%% cont
% OUT.nr() == stride_y()*(IN.nr()-1) + nr() - 2*padding_y()
nr=2;
cont_out_nr = stride*(in_nr-1) + nr - 2*padding;

cont_out_nr2 = stride*(cont_out_nr-1) + nr - 2*padding;

figure(2)
plot(in_nr, cont_out_nr, '-.b')
grid on
hold on
plot(in_nr, cont_out_nr2, '-.g')


%% maxpool
% OUT.nr() == 1+(IN.nr() + 2*padding_y() - FILT_NR)/stride_y()

nr=2;

mp_out_nr = 1+floor((in_nr + 2*padding - nr)/stride);

figure(3)
plot(in_nr, mp_out_nr, '.-b')
grid on

%% comparison


in_nr = 0:500;

padding = 0;

stride = 2;

nr = 3;

con_out_nr = 1+floor((in_nr + 2*padding - nr)/stride);
con_out_nr2 = 1+floor((con_out_nr + 2*padding - nr)/stride);

nr = 3;
cont_out_nr = stride*(in_nr-1) + nr - 2*padding;
cont_out_nr2 = stride*(cont_out_nr-1) + nr - 2*padding;


down4 = in_nr/4;
up4 = down4*4;





figure(4)
hold on
grid on
plot([in_nr up4], [down4 down4], '-r')
plot(up4,down4, '-g')





