close all
clear all

reflection_fit_results=load('reflection_fit_results_nibble3.txt');
reflection_run_params=load('reflection_run_params_nibble3.txt');

time=reflection_fit_results(:,1);
na_log_id=reflection_fit_results(:,2);
fitted_freq=reflection_fit_results(:,5);
fitted_q=reflection_fit_results(:,6);
fitted_gain=reflection_fit_results(:,7);
constant=reflection_fit_results(:,3);
lorentz=reflection_fit_results(:,4);
norm_chi2=reflection_fit_results(:,8);
run_freq=reflection_run_params(:,3);
run_q=reflection_run_params(:,4);
reflection_ch1=reflection_run_params(:,5);

figure
subplot(4,1,1)
plot(time, run_freq)
hold on
plot(time, fitted_freq)
xlabel('Time (s)')
ylabel('Cavity Frequency (MHz)')
legend('Run Freq', 'Fit Freq')

subplot(4,1,2)
plot(time, run_q)
hold on
plot(time, fitted_q)
xlabel('Time (s)')
ylabel('Cavity Q')
legend('Run Q', 'Fitted Q')

subplot(4,1,3)
plot(time, reflection_ch1)
hold on
plot(time, 10*log10(lorentz+constant)-10*log10(constant))
xlabel('Time(s)')
ylabel('Coupling (dB)')
legend('Run Coupling', 'Fit Coupling')

subplot(4,1,4)
plot(time, norm_chi2)
xlabel('Time(s)')
ylabel('Chi2')

bad_fits=find(norm_chi2>10);

bad_scans=na_log_id(bad_fits);
% bad_scans=bad_scans(1:20);

for i=1:length(bad_scans)
    file_name=sprintf('fitted_reflection%6.0f.txt', bad_scans(i));
    data=load(file_name);
    freq=data(:,1);
    ydata=data(:,2);
    yfit=data(:,3);
    figure
    plot(freq, ydata)
    hold on
    plot(freq,yfit)
    legend('data', 'fit')
    title(file_name)
end 