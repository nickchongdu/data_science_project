close all
clear all

load('fit_parameters_sample_nibble1.txt');
load('run_parameters_sample_nibble1.txt');
load('chi2_sample_nibble1.txt');

digitizer_log_id=chi2_sample_nibble1(:,2);
chi2_test=chi2_sample_nibble1(:,5);
chi2_guess=chi2_sample_nibble1(:,4);
freq=chi2_sample_nibble1(:,3);

digitizer_log_names={};
title_names={};
for i=1:length(digitizer_log_id)
    file_name=sprintf('chi2_shape_and_fit_%6.0f.txt', digitizer_log_id(i));
    title_name{i}=sprintf('chi2 guess=%1.3f, chi2 test=%1.3f, freq=%3.3f', chi2_guess(i), chi2_test(i), freq(i));
    digitizer_log_names{i}=file_name;
end 

for i=1:length(digitizer_log_names)
    data=load(digitizer_log_names{i});
    freq=data(:,1);
    ydata=data(:,2);
    yfit=data(:,3);
    figure
    plot(freq, ydata)
    hold on
    plot(freq, yfit)
    legend('data', 'fit')
    plot_title=title_name{i};
    title(plot_title)
end 