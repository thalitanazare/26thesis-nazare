clear all
clc
%Sum = 64 bits
%Mult = 64^1.585bits 

x = [0.1000057140259469; 0.10000428889054676; 0.10000578091301135; 0.1000020609823214; 0.10000813321251358];
N = 6;
add_count_total = 0;
mul_count_total = 0;
for i = 6:N
expr = '0.1972*10*x(i-1) - 0.104*10*x(i-2) + 0.7456e-4*x(i-4)*x(i-2)^3*x(i-1) - 0.2053e-4*x(i-5)*x(i-4)^4 - 0.285e-4*x(i-5)*x(i-1)^4 + 0.2484e-4*x(i-3)^2*x(i-2)^3 + 0.1238e-2*x(i-2)*x(i-1)^2 + 0.4353e-4*x(i-5)^4 + 0.2258e-2*x(i-5)*x(i-2)*x(i-1)^2 + 0.3123e-4*x(i-4)^5 + 0.7531e-3*x(i-1)^4 - 0.2703e-2*x(i-3)^2*x(i-1)^2 - 0.7807e-3*x(i-1)^3 - 0.7077e-4*x(i-3)^2*x(i-2)^2*x(i-1) - 0.3304e-3*x(i-3)*x(i-2)^3 - 0.8847e-2*x(i-5)*x(i-1) + 0.7631e-2*x(i-4)*x(i-1) - 0.3870e-4*x(i-5)^3*x(i-1)^2 + 0.4676e-3*x(i-3)^3*x(i-1)';
[add_count, mul_count] = count_operations(expr);
add_count_total = add_count_total + add_count;
mul_count_total = mul_count_total + mul_count;
x(i) = eval(expr);
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
        if expr(i) == '+' || (expr(i) == '-' && ~(i>1 && (expr(i-1)=='e' || expr(i-1)=='i')))
            add_count = add_count + 1;
        elseif expr(i) == '*'
            mul_count = mul_count + 1;
        elseif expr(i) == '^'
            exponent = str2double(expr(i+1));
            mul_count = mul_count + exponent - 1;
        end
    end
end
