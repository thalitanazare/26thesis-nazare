% Initialize variables
x(1)=5;
y(1)=6;
z(1)=7;
add_count_total = 0;
mul_count_total = 0;



% Loop through iterations
for k = 2:1:2
    expr_x = '0.85919*x(k-1)+0.22489*y(k-1)-0.2833*10^(-2)*x(k-1)*z(k-1)-0.34598*10^(-3)*y(k-1)*z(k-1)-0.12927*10^(-1)-0.69159*10^(-3)*x(k-1)*y(k-1)+0.73257*10^(-3)*x(k-1)^2';
    expr_y = '1.109*y(k-1)-0.6713*10^(-2)*y(k-1)*z(k-1)-0.18688*10^(-1)*x(k-1)*z(k-1)+0.54947*x(k-1)-0.33705*10^(-4)*z(k-1)^2+0.67054*10^(-4)*x(k-1)*y(k-1)-0.36965*10^(-3)*x(k-1)^2';
    expr_z = '1.0077*z(k-1)+0.93353*10^(-2)*x(k-1)*y(k-1)-0.21708*10^(-2)*z(k-1)^2+0.72469*10^(-2)*x(k-1)^2+0.76919*10^(-2)*y(k-1)^2-0.47834+0.48760*10^(-4)*y(k-1)*z(k-1)';

    [add_count_x, mul_count_x] = count_operations(expr_x);
    [add_count_y, mul_count_y] = count_operations(expr_y);
    [add_count_z, mul_count_z] = count_operations(expr_z);
    
    add_count_total = add_count_total + add_count_x + add_count_y + add_count_z;
    mul_count_total = mul_count_total + mul_count_x + mul_count_y + mul_count_z;

    x(k) = eval(expr_x);
    y(k) = eval(expr_y);
    z(k) = eval(expr_z);
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

% Reuse the count_operations function from the previous script
function [add_count, mul_count] = count_operations(expr)
    add_count = 0;
    mul_count = 0;
    for i = 1:numel(expr)
        if expr(i) == '+' || (expr(i) == '-' && ~(i>1 && (expr(i-1)=='k' || expr(i-1)=='(')))
            add_count = add_count + 1;
        elseif expr(i) == '*'
            mul_count = mul_count + 1;
        elseif expr(i) == '^'
            if i < numel(expr) && expr(i+1) ~= '('
                exponent = str2double(expr(i+1));
                mul_count = mul_count + exponent - 1;
            end
        end
    end
end
