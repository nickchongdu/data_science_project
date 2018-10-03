%% Phys576 HW #1
close all
clear all

%% Problem 1
num_points=10^5;
average_events=50.1
data=poissrnd(average_events,1, num_points);
h1=histogram(data, 'BinWidth',1);
binlimits=h1.BinLimits;
%binwidths=h1.BinWidth;
min_x=binlimits(1);
max_x=binlimits(2);
xout=linspace(min_x, max_x, h1.NumBins);
n=h1.Values;

%[n, xout]=hist(data, 123)
figure
bar(xout,n, 'barwidth', 1', 'basevalue', 0.1)
set(gca, 'YScale', 'log')
xlabel('Events')
ylabel('log(counts)')

%% Problem 2 
pdist=n/(num_points);
figure
bar(xout, pdist, 'barwidth', 1', 'basevalue', 0)

integral=sum(pdist)

%% Problem 3
events=80;
