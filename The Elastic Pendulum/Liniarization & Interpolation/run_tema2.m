clc, clear, close all

%% Configurare model
T = 500; %timp de simulare
t = linspace(0, T, 1e3).';

f = @(t, k) k.*double(t>=0); %treapta

%setare parametri modelului

load_system('tema1');
set_param('tema1', 'StopTime', num2str(T));

%Definirea parametrilor

g = 9.8;
m = 2.35;
l = 2.58;
zeta = 5.04;
k = 0.31;

params.g = g;
params.m = m;
params.l = l;
params.zeta = zeta;
params.k = k;

%Definire magistrala de comunicare pentru params
params_info = Simulink.Bus.createObject(params);
params_bus = evalin('base', params_info.busName);

%% Pct a)

ustar = 1;

%Trim
[xstar_trim, ustar_trim, ystar_trim, ~] = trim('model_pin', [], ustar, [], [], 1, []);

%Alternativ

u = timeseries(f(t, ustar), t);

load_system('tema2');
set_param('tema2', 'StopTime', num2str(t(end)))
out = sim('tema2');

ystar1_sim = y1.Data(end);
ystar2_sim = y2.Data(end);

xstar_sim = y.Data(end, :).';

%Liniarizare

[A,B,C,D] = linmod('model_pin', xstar_trim, ustar);

%Simulare

sys = ss(A,B,C,D);
u2 = f(t, ustar);
u = timeseries(u2, t);
out = sim('tema2');

ylin = lsim(sys, u2 - repmat(ustar, length(t), 1), t, - xstar_trim) + ystar_trim';

ystar1_lin = ylin(:, 1); %am extras prima coloana primita la lsim pentru a indica faptul ca sunt valorile primei iesire liniarizata
ystar2_lin = ylin(:, 2); %la fel am facut si pentru a doua iesire

%% Pct b)

figure;
plot(y1.Time, y1.Data, '--k', 'LineWidth', 1.3); hold on
plot(t, ystar1_lin, '-b'); hold on
xlim([0 50]);
legend('y1Neliniara', 'y1Liniara');
title('Graficul primei iesire y1');
%in cazul primei iesire se vede diferenta dintre graficile

figure;
plot(y2.Time, y2.Data, '--k', 'LineWidth', 1.3); hold on
plot(t, ystar2_lin, '-b'); hold on
legend('y2Neliniara', 'y2Liniara');
title('Graficul al doilea iesire y2');
%in cazul al doilea iesire graficile se suprapune

p1=polyfit(ustar, ystar1_sim, 3);
p2=polyfit(t, ystar1_lin, 3);
  
ustar_1=t(1):.1:t(end);
  
ystar_1_sim = polyval(p1, ustar_1);
ystar_1_lin = polyval(p2, ustar_1);

figure;
plot(ustar_1, ystar_1_sim, "--b"), hold on
plot(ustar_1, ystar_1_lin, "--r"), hold on
ylim([-2500000 2500000]);
legend('Caracteristica statica neliniar', 'Caracteristica statica liniar');
title('Graficul caracteristicile statice liniara/neliniara y1');

p3=polyfit(ustar, ystar2_sim, 3);
p4=polyfit(t, ystar2_lin, 3);
  
ustar_2=t(1):.1:t(end);
  
ystar_2_sim = polyval(p3, ustar_2);
ystar_2_lin = polyval(p4, ustar_2);

figure;
plot(ustar_2, ystar_2_sim, "--b"), hold on
plot(ustar_2, ystar_2_lin, "--r"), hold on
ylim([-1000000000 1000000000]);
legend('Caracteristica statica neliniar', 'Caracteristica statica liniar');
title('Graficul caracteristicile statice liniara/neliniara y2');