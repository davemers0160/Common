iq_reshape = reshape(iq(1:2000), 200, []).';

figure;
set(gcf,'position',([50,50,1600,500]),'color','w')
subplot(2,1,1);
hold on;
grid on;
box on;
subplot(2,1,2);
hold on;
grid on;
box on;
for idx=1:size(iq_reshape,1)
    subplot(2,1,1);
    plot(real(iq_reshape(idx, :)), 'b')
    subplot(2,1,2);
    plot(imag(iq_reshape(idx, :)), 'b')

end