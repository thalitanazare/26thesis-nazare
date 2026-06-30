% clear all
% clc
%Sum = 64 bits
%Mult = (1^1.585) * 64bits

x=[0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01];
N = 11;
add_count_total = 0;
mul_count_total = 0;
for k = 11:N
expr = '0.24662*10*x(k-1) - 0.16423*10*x(k-2) + 0.60992*x(k-3) + 0.73012e-1*x(k-5)^2*x(k-10)^2 + 0.38566*x(k-3)*x(k-10) + 0.66999*x(k-1)*x(k-10)^2+ 0.88364*x(k-1)^3- 0.67300*x(k-4)*x(k-10)^2- 0.11929*10*x(k-1)^2 - 0.50451e-1*x(k-4)*x(k-5) - 0.24765*x(k-1)^4 + 0.42081*x(k-4)*x(k-9)*x(k-10)^2- 0.70406*x(k-1)*x(k-10)^3- 0.14089*x(k-5)*x(k-8)^2+ 0.14807*x(k-1)*x(k-7)*x(k-10)';
[add_count, mul_count] = count_operations(expr);
add_count_total = add_count_total + add_count;
mul_count_total = mul_count_total + mul_count;
x(k) = eval(expr);
end

disp(['total addition times: ' num2str(add_count_total)]);
disp(['total multiplication times: ' num2str(mul_count_total)]);
Sum = add_count_total * 64;
Mult= mul_count_total * 64 ^1.585;
Total = add_count_total * 64 + mul_count_total * 64 ^1.585;
disp(['Sum = ' num2str(Sum) 'bits']);
disp(['Mult = ' num2str(Mult) 'bits']);
disp(['Total = ' num2str(Total) 'bits']);
fac = 1.5773e-04; 
CO2_emission = (Sum + Mult) * fac; 
disp(['CO2 emission = ' num2str(CO2_emission) 'mgCO2e']);

function [add_count, mul_count] = count_operations(expr)
    add_count = 0;
    mul_count = 0;
    for i = 1:numel(expr)
        if expr(i) == '+' || (expr(i) == '-' && ~(i>1 && (expr(i-1)=='e' || expr(i-1)=='k')))
            add_count = add_count + 1;
        elseif expr(i) == '*'
            mul_count = mul_count + 1;
        elseif expr(i) == '^'
            exponent = str2double(expr(i+1));
            mul_count = mul_count + exponent - 1;
        end
    end
end
