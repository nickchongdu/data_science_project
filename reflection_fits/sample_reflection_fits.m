close all
clear all

reflection_fit_results=load('reflection_fit_results_nibble1.txt');
reflection_run_params=load('reflection_run_params_nibble1.txt');

time=reflection_fit_results(:,1);
na_log_id=reflection_fit_results(:,2);
fitted_freq=reflection_fit_results(:,5);
fitted_q=reflection_fit_results(:,6);
fitted_gain=reflection_fit_results(:,7);
constant=reflection_fit_results(:,3);
lorentz=reflection_fit_results(:,4);

run_freq=reflection_run_params(:,3);
run_q=reflection_run_params(:,4);
reflection_run_params(:,5);

na_log_names={};
title_names={};
legend_names={}
for i=1:length(na_log_id)
    file_name=sprintf('fitted_reflection%6.0f.txt', na_log_id(i));
    fprintf(file_name)
    fprintf("\n")
    title_name{i}=sprintf('Measured freq=%3.3f,Measured Q=%5.0f', run_freq(i),run_q(i));
    legend_names{i}=sprintf('Fit=Fitted Freq=%3.3f, Fitted Q=%5.0f',fitted_freq(i),fitted_q(i));
    na_log_names{i}=file_name;
end 
for i=1:length(na_log_names)
    data=load(na_log_names{i});
    freq=data(:,1);
    ydata=data(:,2);
    yfit=data(:,3);
    figure
    plot(freq, ydata)
    hold on
    plot(freq, yfit)
    legend('data', legend_names{i})
    plot_title=title_name{i};
    title(plot_title)
end 
figure
plot(time, run_freq)
hold on
plot(time, fitted_freq)
xlabel('Time (s)')
ylabel('Cavity Frequency (MHz)')
legend('Run Freq', 'Fit Freq')

figure
plot(time, run_q)
hold on
plot(time, fitted_q)
xlabel('time(s)')
ylabel('Cavity Q')
legend('Run Q', 'Fitted Q')