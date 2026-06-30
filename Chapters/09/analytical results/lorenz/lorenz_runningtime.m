clear all;
close all;
clc;

num_iter = 50;
normal_time = zeros(1, num_iter);
horner_time = zeros(1, num_iter);
simplify_time = zeros(1, num_iter);
N=1000;
for iter = 1:num_iter
    % Normal

    tic
    x(1)=5;
    y(1)=6;
    z(1)=7;
    for i = 2:N
        x(i)=0.85919*x(i-1)+0.22489*y(i-1)-0.2833*10^(-2)*x(i-1)*z(i-1)-0.34598*10^(-3)*y(i-1)*z(i-1)-0.12927*10^(-1)-0.69159*10^(-3)*x(i-1)*y(i-1)+0.73257*10^(-3)*x(i-1)^2;
        y(i)=1.109*y(i-1)-0.6713*10^(-2)*y(i-1)*z(i-1)-0.18688*10^(-1)*x(i-1)*z(i-1)+0.54947*x(i-1)-0.33705*10^(-4)*z(i-1)^2+0.67054*10^(-4)*x(i-1)*y(i-1)-0.36965*10^(-3)*x(i-1)^2;
        z(i)=1.0077*z(i-1)+0.93353*10^(-2)*x(i-1)*y(i-1)-0.21708*10^(-2)*z(i-1)^2+0.72469*10^(-2)*x(i-1)^2+0.76919*10^(-2)*y(i-1)^2-0.47834+0.48760*10^(-4)*y(i-1)*z(i-1);
    end
    normal_time(iter) = toc;



    % Horner's method

    tic
    x2(1)=5;
    y2(1)=6;
    z2(1)=7;
    for i = 2:N
        x2(i)=x2(i-1)*(0.85919-0.2833*10^(-2)*z2(i-1)-0.69159*10^(-3)*y2(i-1)+0.73257*10^(-3)*x2(i-1))+y2(i-1)*(0.22489-0.34598*10^(-3)*z2(i-1))-0.12927*10^(-1);
        y2(i)=z2(i-1)*(-0.6713*10^(-2)*y2(i-1)-0.18688*10^(-1)*x2(i-1)-0.33705*10^(-4)*z2(i-1))+x2(i-1)*(0.54947+0.67054*10^(-4)*y2(i-1)-0.36965*10^(-3)*x2(i-1))+1.109*y2(i-1);
        z2(i)=y2(i-1)*(0.93353*10^(-2)*x2(i-1)+0.76919*10^(-2)*y2(i-1)+0.48760*10^(-4)*z2(i-1))+z2(i-1)*(1.0077-0.21708*10^(-2)*z2(i-1))+0.72469*10^(-2)*x2(i-1)^2-0.47834;
    end
    horner_time(iter) = toc;

    % Simplify Method
    tic
    x3(1)=5;
    y3(1)=6;
    z3(1)=7;
    for i = 2:N
        x3(i)=(85919*x3(i-1))/100000 + (22489*y3(i-1))/100000 - (6378791866968395*x3(i-1)*y3(i-1))/9223372036854775808 -...
            (6532453245102395*x3(i-1)*z3(i-1))/2305843009213693952 - (6382204514622031*y3(i-1)*z3(i-1))/18446744073709551616 + ...
            (422297853314919*x3(i-1)^2)/576460752303423488 - 1862977036256589/144115188075855872;
        y3(i)=(54947*x3(i-1))/100000 + (1109*y3(i-1))/1000 + (2473855954237041*x3(i-1)*y3(i-1))/36893488147419103232 -...
            (292*x3(i-1)*z3(i-1))/15625 - (1934890515106441*y3(i-1)*z3(i-1))/288230376151711744 -...
            (426177434177921*x3(i-1)^2)/1152921504606846976 - (1243495018008761*z3(i-1)^2)/36893488147419103232;
        z3(i)=(10077*z3(i-1))/10000 + (5381434060978149*x3(i-1)*y3(i-1))/576460752303423488 +...
            (3597852964136311*y3(i-1)*z3(i-1))/73786976294838206464 + (8355106851735359*x3(i-1)^2)/1152921504606846976 +...
            (8868156921285407*y3(i-1)^2)/1152921504606846976 - (5005524004401087*z3(i-1)^2)/2305843009213693952 - 23917/50000;
    end
    simplify_time(iter)=toc;


end

% % Calculate mean and standard deviation
normal_mean = mean(normal_time);
normal_std = std(normal_time);
horner_mean = mean(horner_time);
horner_std = std(horner_time);
simplify_mean = mean(simplify_time);
simplify_std = std(simplify_time);

% Display results
fprintf('Normal method: \n');
fprintf('Mean time: %.15f\n', normal_mean);
fprintf('Standard deviation: %.15f\n', normal_std);
fprintf('\n');
fprintf('Horner''s method: \n');
fprintf('Mean time: %.15f\n', horner_mean);
fprintf('Standard deviation: %.15f\n', horner_std);
fprintf('\n');
fprintf('Simplify method: \n');
fprintf('Mean time: %.15f\n', simplify_mean);
fprintf('Standard deviation: %.15f\n', simplify_std);

% figure(1)
% plot(x,'k')
% figure(2)
% plot(y,'k')
% figure(3)
% plot(z,'k')
% figure(4)
% plot3(x,y,z,'k')
%
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

figure
plot(x)
hold on
plot(x2)
hold on
plot(x3)