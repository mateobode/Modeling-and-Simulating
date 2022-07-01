clc, clear, close all

g = 9.8;
m = 2.35;
l = 2.58;
zeta = 5.04;
k = 0.31;

params.g = 10;
params.m = m;
params.l = l;
params.zeta = zeta;
params.k = k;

params_info = Simulink.Bus.createObject(params);
params_bus = evalin('base', params_info.busName);

Tmax = 50;

load_system('model');
set_param('model', 'StopTime', num2str(Tmax));

t = linspace(0, Tmax ,100).';
st = double(t>=0); %treapta unitara

ustar = [0.1; 0.3; 1; 2.4];
ystar = zeros(4,1);
ystar1 = zeros(4,1);

for i = 1:length(ustar)
    u = timeseries(ustar(i) .* st, t);
    out = sim('model');
    
    ystar(i) = theta.Data(end);
    ystar1(i) = x.Data(end);
end

figure('Name', 'Cerinta 1 grafic theta');
plot(theta);
hold on
figure('Name', 'Cerinta 1 grafic x');
plot(x);
hold on

figure('Name', 'Caracteristica Statica ystar');
plot(ustar, ystar, 'bs');
hold on

p = polyfit(ustar, ystar, 3);
p1 = polyfit(ustar, ystar1, 3);

ustar_2 = ustar(1):0.1:ustar(end);
ystar_2 = polyval(p, ustar_2);
ystar_3 = polyval(p1, ustar_2);


plot(ustar_2, ystar_2, '--m');

figure('Name', 'Caracteristica Statica ystar1');
plot(ustar, ystar1, 'bs');
hold on
plot(ustar_2, ystar_3, '--m');
hold off
hold off

