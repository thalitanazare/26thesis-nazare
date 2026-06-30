clear all;
close all;
clc;

num_iter = 50;
normal_time = zeros(1, num_iter);
horner_time = zeros(1, num_iter);

for iter = 1:num_iter
% Normal

tic
x(1)=0.003;
y(1)=0.005;
z(1)=0.002;

for i = 2:1:6000
    x(i)=0.99982*x(i-1)-0.24884*10^(-1)*y(i-1)-0.10431*10^(-4)*z(i-1)^2-0.51675*10^(-2)*y(i-1)*z(i-1)-0.32205*10^(-2)*x(i-1)*z(i-1);
    y(i)=1.0048*y(i-1)+0.25786*10^(-1)*x(i-1)-0.64615*10^(-3)*y(i-1)*z(i-1)-0.81375*10^(-3)*z(i-1)-0.98027*10^(-4)*x(i-1)*x(i-1);
    z(i)=0.86209*z(i-1)+0.24939*10^(-1)*x(i-1)*z(i-1)+0.81343*10^(-3)*y(i-1)*z(i-1)+0.17808*10^(-3)*x(i-1)^2-0.61844*10^(-3)*z(i-1)^2;
end
 normal_time(iter) = toc;


% Horner's method

tic
x2(1)=0.003;
y2(1)=0.005;
z2(1)=0.002;

for i = 2:1:6000
    x2(i)=z2(i-1)*(0.10431*10^(-4)*z2(i-1)-0.51675*10^(-2)*y2(i-1)-0.32205*10^(-2)*x2(i-1))+0.99982*x2(i-1)-0.24884*10^(-1)*y2(i-1);
    y2(i)=y2(i-1)*(1.0048-0.64615*10^(-3)*z2(i-1))+x2(i-1)*(0.25786*10^(-1)-0.98027*10^(-4)*x2(i-1))-0.81375*10^(-3)*z2(i-1);
    z2(i)=z2(i-1)*(0.86209+0.24939*10^(-1)*x2(i-1)+0.81343*10^(-3)*y2(i-1)-0.61844*10^(-3)*z2(i-1))+0.17808*10^(-3)*x2(i-1)^2;
end
horner_time(iter) = toc;
end

% Calculate mean and standard deviation
normal_mean = mean(normal_time);
normal_std = std(normal_time);
horner_mean = mean(horner_time);
horner_std = std(horner_time);

% Display results
fprintf('Normal method: \n');
fprintf('Mean time: %.15f\n', normal_mean);
fprintf('Standard deviation: %.15f\n', normal_std);
fprintf('\n');
fprintf('Horner''s method: \n');
fprintf('Mean time: %.15f\n', horner_mean);
fprintf('Standard deviation: %.15f\n', horner_std);


% figure(1)
% plot(x,'k')
% figure(2)
% plot(y,'k')
% figure(3)
% plot(z,'k')
% figure(4)
% plot3(x,y,z,'k')
% 
% figure(5)
% plot(x2,'k')
% figure(6)
% plot(y2,'k')
% figure(7)
% plot(z2,'k')
% figure(8)
% plot3(x2,y2,z2,'k')
% 
% figure(9)
% plot(x,'k')
% hold on
% plot(x2,'b')