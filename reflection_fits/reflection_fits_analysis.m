close all
clear all

reflection_fit_results=load('reflection_fit_results_nibble2.txt');
reflection_run_params=load('reflection_run_params_nibble2.txt');

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
xlabel('Time (s)')
ylabel('Cavity Q')
legend('Run Q', 'Fitted Q')