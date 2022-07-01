
%% functia de tranfer a sistemului dat
s = tf('s');
H = (s-1.5)/((s+1.5)*(s*s+1.2*s+2.25));

%% pct a
Te=0.5;

Hd = c2d(H,Te,'tustin');

figure (1);
step(H);
hold on
step(Hd);
title('Raspuns la treapta');
legend('continuu', 'tustin');
xlim([0 10]);

t = linspace(0,5,1000);
u = (3*(cos(5*t))) + (2*(sin(10*t)));

figure(2)
[num1, den1] = tfdata(Hd); 
[dx, ~] = dlsim(num1{1}, den1{1}, u);

[num, den] = tfdata(H); 
[x, ~] = lsim(num{1}, den{1}, u, t);

%am ilustrat pe ambele raspunsuri in acelasi grafic
plot(t,dx);
hold on
plot(t,x);
title('Raspuns in timp la intrarea u');
legend('sistemul discretizat', 'sistemul continuu');

%% pct b
z = tf('z')
H_d = tf(num1{1,1}, den1{1,1}, z);

y1 = 0;
y = 0;
u1 = 0;
u = 0;
n = 0;

while 1
    n = n+1;
    u1 = u;
    if 5<=n && n<10
        u = 2;
    else
        u = 0;
    end
    y1 = y;
    y = -1 .* H_d.Numerator .* y1 + u + H_d.Denominator .* u1;
end