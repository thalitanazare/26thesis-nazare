executablePath = 'C:\Users\jorda\OneDrive\Documents\MATLAB\Spur Example\ProcessorUtilization.exe';
outputPath = 'C:\Users\jorda\OneDrive\Documents\MATLAB\Spur Example\Output.txt';

tau = 15;
beta = 0.2;
gamma = 0.1;
n = 12000; % Number of iterations
t = zeros(n,1);
% Initial conditions
x0 = 1.2;
x = zeros(n, 1);
x(1) = x0;
pause('on');
% Mackey-Glass system
for k = 1:n-1
    if k < tau
        x(k+1) = x(k) + beta*x(k);
    else
        x(k+1) = x(k) + beta*x(k-tau+1) / (1 + x(k-tau+1)^10) - gamma*x(k);
        t(k) = k;
    end
end
y1 = x(1000:12000);
t = t(1000:12000);
Y0 = y1(6001:6010);
numLoops = 1;

% Initialize a cell array to store CPU utilization data from each iteration
cpuTime_data = zeros(1,numLoops);
CPUUtilization_data = cell(1, numLoops);
monitor = MonitorCPU(executablePath, outputPath);
system('start python pmd.py')
for k = 1:numLoops
    monitor.start()
    pause(1);
    y = MGHornerEval(Y0,10000000);
    pause(1);
    data = monitor.stop();
    
    % Extract CPU utilization column
    CPUUtilization = data.data(:,1:2);
    cpuTime_data(k) = sum(data.data(:,3));
    % Store the CPU utilization data for this iteration in a cell array
    CPUUtilization_data{k} = CPUUtilization;
    disp(k);
end
system('taskkill /F /IM python3.11.exe')
%Determine the maximum length of CPU utilization data
max_length = max(cellfun(@(x) size(x, 1), CPUUtilization_data));

%Create a matrix to store CPU utilization data for all iterations
num_loops = length(CPUUtilization_data);
CPUUtilization_matrix = NaN(max_length, 2, num_loops);
for k = 1:num_loops
    current_length = size(CPUUtilization_data{k}, 1);
    % Linear interpolation to fill missing data points
    t_interpolated = linspace(CPUUtilization_data{k}(1, 1), CPUUtilization_data{k}(end, 1), max_length);
    CPUUtilization_interpolated = interp1(CPUUtilization_data{k}(:, 1), CPUUtilization_data{k}(:, 2), t_interpolated);
    CPUUtilization_matrix(:, :, k) = [t_interpolated', CPUUtilization_interpolated'];
end
%Compute the average CPU utilization signal
average_CPU_utilization = mean(CPUUtilization_matrix(:, 2, :), 3, 'omitnan');
average_CPU_time = mean(cpuTime_data);
% Plot the average CPU utilization signal
error = rmse(y1(6001-1000:12000-1000),y(1:6000));
function error = rmse(predictions, targets)
    differences = predictions - targets;  % Subtract observed from predicted values
    squaredDifferences = differences .^ 2;  % Square the differences
    meanOfSquaredDifferences = mean(squaredDifferences);  % Find the mean of squared differences
    error = sqrt(meanOfSquaredDifferences);  % Take the square root
end