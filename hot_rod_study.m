close all
time=Tampsnibble7(:,1);
chi2=chi2nibble7(:,3);
freqs=chi2nibble7(:,2);
a1_parameters=fitparametersnibble7(:,3);
a2_parameters=fitparametersnibble7(:,4);
a3_parameters=fitparametersnibble7(:,5);
a4_parameters=fitparametersnibble7(:,6);
Tcav=runparametersnibble7(:,3);
Tsquid=runparametersnibble7(:,4);
jpa_gain=runparametersnibble7(:,5);
reflection=runparametersnibble7(:,6);

time_days=(time-time(1))/86400;

%%Do some filtering of the plots, (remove areas where chi2 is large)
bad_indices=find(chi2>2| abs(a1_parameters)>30 | abs(a2_parameters)>5 | abs(a3_parameters)>5 | abs(a4_parameters)>1 | Tcav>1 | Tsquid>1);
% num_bad_scans=length(bad_indices)
time_days(bad_indices)=[];
%chi2_plot=chi2(:,3);
chi2(bad_indices)=[];
a1_parameters(bad_indices)=[];
a2_parameters(bad_indices)=[];
a3_parameters(bad_indices)=[];
a4_parameters(bad_indices)=[];
freqs(bad_indices)=[];
reflection(bad_indices)=[];
jpa_gain(bad_indices)=[];
Tcav(bad_indices)=[];
Tsquid(bad_indices)=[];

figure
subplot(2,2,1)
plot(time_days, a1_parameters)
subplot(2,2,2)
plot(time_days, a2_parameters)
subplot(2,2,3)
plot(time_days, a3_parameters)
subplot(2,2,4)
plot(time_days, a4_parameters)

Tcav_hot_rod=[];
delta=[];
gain=[];
exitval=[];
fvals=[];

for i=1:length(a1_parameters)
    [soln,fval,exitflag]=rf_solver_hot_rod(a1_parameters(i),a2_parameters(i),a3_parameters(i),Tcav(i),Tsquid(i),reflection(i));
    gain(i)=soln(1);
    Tcav_hot_rod(i)=soln(2);
    delta(i)=soln(3);
    exitval(i)=exitflag;
    fvals(i, 1:3)=fval;
end

Tcav_analysis=Tcav;
tplot=time_days;
jpa_gain_plot=jpa_gain;

bad_solns=find(exitval<=0);
size(bad_solns)

Gain_Tsys=a1_parameters+a2_parameters;
Tsys=Gain_Tsys./gain';

Tsys(bad_solns)=[];
Tcav_hot_rod(bad_solns)=[];
delta(bad_solns)=[];
gain(bad_solns)=[];
Tcav_analysis(bad_solns)=[];
tplot(bad_solns)=[];
Tcav_excess=Tcav_hot_rod-Tcav_analysis';
jpa_gain_plot(bad_solns)=[];
freqs(bad_solns)=[];

figure
plot(tplot,Tcav_excess)
xlabel('Time')
ylabel('Hot Rod Excess Temp (K)')

figure
plot(tplot,gain)
xlabel('Time')
ylabel('Gain')

freq_diff=diff(freqs);
t_diff=diff(tplot);

rod_speed=abs(freq_diff./t_diff);

figure
yyaxis left
plot(tplot, Tcav_excess)
ylabel('Hot Rod Excess Temp (K)')
hold on
yyaxis right
plot(tplot(1:length(rod_speed)),rod_speed)
xlabel('Time')
ylabel('Rod Speed (MHz/day)')

figure
plot(rod_speed, Tcav_excess(1:length(rod_speed)))
xlabel('Rod Speed')
ylabel('Hot Rod excess temp (K)')

figure
plot(tplot, Tsys)
xlabel('Time')
ylabel('System Noise Temp')

function [soln,fval, exitflag]=rf_solver_hot_rod(a1,a2,a3,Tcav,Tsquid,reflection)
alpha1=10^(-0.39/10);
alpha2=10^(-0.39/10);
S13=10^(-17/10);
% S13=x(2);
Tamp_guess=0.1;
gain_guess=a2/(Tcav*alpha1*alpha2-Tsquid*(alpha1^2*alpha2^2+S13));
fun=@(x)rf_eqns(x, a1,a2,a3,Tamp_guess,Tsquid,alpha1,alpha2,S13,reflection);
x0=[gain_guess, Tcav, 0];
options=optimoptions('fsolve','OptimalityTolerance', 10^-7,'MaxFunctionEvaluations', 100000,'MaxIterations',100000);
[soln,fval,exitflag]=fsolve(fun, x0, options);
end

function F=rf_eqns(x,a1,a2,a3,Tamp_guess,Tsquid, alpha1,alpha2,S13,reflection)
% Tcav=0.13;
% Tsquid=0.27;
% alpha1=10^(-0.39/10);
% alpha2=10^(-0.39/10);
% S13=10^(-16/10);
reflect=10^(reflection/10);
a1_offset=Tsquid*(1-alpha1)*alpha1*alpha2^2+x(2)*(1-alpha2)*alpha1+x(2)*(1-alpha2)*alpha1+Tsquid*(1-alpha1);%+(1-S13)*Tsquid;
a2_offset= -Tsquid*(1-alpha1)*alpha1*alpha2^2-x(2)*(1-alpha2)*alpha1*alpha2;
F(1)=a1-x(1)*(Tamp_guess+Tsquid*(alpha1^2*alpha2^2+S13+2*alpha1*alpha2*sqrt(S13)*cos(x(3)))+a1_offset);
F(2)=a2-x(1)*(x(2)*alpha1*alpha2*(1-reflect)+Tsquid*(reflect*alpha1^2*alpha2^2)-Tsquid*(alpha1^2*alpha2^2+2*alpha1*alpha2*sqrt(S13)*cos(x(3)))+a2_offset);
F(3)=a3-x(1)*(Tsquid*2*alpha1*alpha2*sqrt(S13)*sin(x(3)));
end