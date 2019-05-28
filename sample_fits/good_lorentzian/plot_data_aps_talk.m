close all
y1_norm=y1-mean(y1);
y2_norm=y2-mean(y2);
y3_norm=y3-mean(y3);
y4_norm=y4-mean(y4);
y5_norm=y5-mean(y5);
y6_norm=y6-mean(y6);
y7_norm=y7-mean(y7);
y8_norm=y8-mean(y8);
y9_norm=y9-mean(y9);

vert_span=1.0;
yspace=linspace(0,vert_span,9);

y1_plot=y1_norm+yspace(1);
y2_plot=y2_norm+yspace(2);
y3_plot=y3_norm+yspace(3);
y4_plot=y4_norm+yspace(4);
y5_plot=y5_norm+yspace(5);
y6_plot=y6_norm+yspace(6);
y7_plot=y7_norm+yspace(7);
y8_plot=y8_norm+yspace(8);
y9_plot=y9_norm+yspace(9);

y1_fit_plot=y1_fit-mean(y1)+yspace(1);
y2_fit_plot=y2_fit-mean(y2)+yspace(2);
y3_fit_plot=y3_fit-mean(y3)+yspace(3);
y4_fit_plot=y4_fit-mean(y4)+yspace(4);
y5_fit_plot=y5_fit-mean(y5)+yspace(5);
y6_fit_plot=y6_fit-mean(y6)+yspace(6);
y7_fit_plot=y7_fit-mean(y7)+yspace(7);
y8_fit_plot=y8_fit-mean(y8)+yspace(8);
y9_fit_plot=y9_fit-mean(y9)+yspace(9);

plot(x1,y1_plot, 'k')
hold on
plot(x1,y1_fit_plot, 'r')
plot(x2,y2_plot, 'k')
plot(x2,y2_fit_plot,'r')
plot(x3,y3_plot, 'k')
plot(x3,y3_fit_plot, 'r')
plot(x4,y4_plot, 'k')
plot(x4, y4_fit_plot, 'r')
plot(x5,y5_plot, 'k')
plot(x5,y5_fit_plot, 'r')
plot(x6,y6_plot, 'k')
plot(x6,y6_fit_plot,'r')
plot(x7,y7_plot, 'k')
plot(x7,y7_fit_plot, 'r')
plot(x8,y8_plot, 'k')
plot(x8, y8_fit_plot, 'r')
plot(x9,y9_plot, 'k')
plot(x9,y9_fit_plot, 'r')
set(gca, 'YTickLabel', [])
set(gca, 'XTickLabel', [])
yticks([])
xlabel('Frequency (MHz)')
ylabel('Single Raw Spectra (Offset)')
