clc, clear, close all

%% Configurare model
%setare parametri modelului

T = 500;
t = linspace(0, T, 1e3).';

load_system('tema2');
set_param('tema2', 'StopTime', num2str(T));

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

%% Pct c)

x0 = [0; 0; 0; 0];
ustar = [1, 2];

for i= 1:length(ustar)
    [xst{i} , ust{i} , yst{i}, ~] = trim('model_pin',[],ustar(i),[],[],1,[]);
    [A{i} , B{i} , C{i} , D{i}] = linmod('model_pin', xst{i} ,ustar(i));       
end

u2 = 1.98 * double(t<=250)+ 0.85 * (t>250);
u = timeseries(u2, t);

out = sim('tema2');
sigma = 2 * double(t<=250)+ 1 * (t>250);

alternanta = find(diff(sigma) ~= 0);
alternanta = [1 alternanta length(t)+1];

y_lpp = [];
y1_lpp = [];
y2_lpp = [];

for i = 1:length(alternanta)-1
    liniarizCrt = sigma(alternanta(i) + 1);
    timpCrt = t(alternanta(i):alternanta(i+1)-1) - t(alternanta(i));
    uCrt = u2(alternanta(i):alternanta(i+1)-1);
    
    sys = ss(A{liniarizCrt}, B{liniarizCrt}, C{liniarizCrt}, D{liniarizCrt});
    [ylin, ~, xlin] = lsim(sys, uCrt - ust{liniarizCrt}, timpCrt, x0 - xst{liniarizCrt});
    
    y_lpp = [y_lpp; ylin + yst{liniarizCrt}'];
    x0 = xlin(end, :).' + xst{liniarizCrt};
    
    y1_lpp = y_lpp(:, 1);
    y2_lpp = y_lpp(:, 2);
    
end

figure;
plot(y1.Time, y1.Data, '--k', 'LineWidth', 1.3); hold on
plot(t, y1_lpp, '-b'); hold on
legend('y1Neliniara', 'y1Liniara');
title('Graficul primei iesire y1');

figure;
plot(y2.Time, y2.Data, '--k', 'LineWidth', 1.3); hold on
plot(t, y2_lpp, '-b'); hold on
legend('y2Neliniara', 'y2Liniara');
title('Graficul al doilea iesire y2');
%in cazul al doilea iesire graficile se suprapune
