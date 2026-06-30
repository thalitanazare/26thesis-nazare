clear all
clc
close all

% Loading data from CSV files
lw_data = readtable('MGWOH.csv');
lh_data = readtable('MGWH.csv');

% Renaming columns for clarity
lw_data.Properties.VariableNames = {'Time', 'Power'};
lh_data.Properties.VariableNames = {'Time', 'Power'};

% Displaying the first rows of each table to understand the structure
head(lw_data)
head(lh_data)

figure;
hold on;
plot(lw_data.Time, lw_data.Power, 'Color', '#800080', 'LineWidth', 1.5, 'DisplayName', 'Without Horner');
plot(lh_data.Time, lh_data.Power, 'Color', [0, 168/255, 107/255], 'LineWidth', 1.5, 'DisplayName', 'With Horner');

title('PMD data collected for the same total iterations $N = 10^7$', 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
xlabel('Time (ms)', 'FontSize', 18, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
ylabel('Power (W)', 'FontSize', 18, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
legend('FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
grid on;
maxTime = max([max(lw_data.Time), max(lh_data.Time)]);
xlim([min(lw_data.Time), maxTime]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 16);

fig = gcf;
fig.Units = 'inches';
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

% Calculating the total energy spent for each model
% Energy can be approximated by integrating power over time.

% Calculating total energy for lw_data
energy_lw = trapz(lw_data.Time, lw_data.Power);
fprintf('Total energy for LWOH: %f energy units\n', energy_lw);

% Calculating total energy for lh_data
energy_lh = trapz(lh_data.Time, lh_data.Power);
fprintf('Total energy for LWH: %f energy units\n', energy_lh);

% Calculating metrics for LWOH
metrics_lw = calculate_metrics(lw_data);

% Calculating metrics for LWH
metrics_lh = calculate_metrics(lh_data);

% Displaying the metrics
disp('Metrics for Lorenz without Horner (LWOH):');
disp(metrics_lw);

disp('Metrics for Lorenz with Horner (LWH):');
disp(metrics_lh);

cost_per_kwh = 0.3567; % Replace 0.3567 with the current value if you have that information

% Converting energy from joules to kWh
energy_lw_kwh = energy_lw / 3600000;
energy_lh_kwh = energy_lh / 3600000;

% Calculating the total cost of the energy consumed by each model
total_cost_lw = energy_lw_kwh * cost_per_kwh;
total_cost_lh = energy_lh_kwh * cost_per_kwh;

fprintf('Total cost LWOH: %f\n', total_cost_lw);
fprintf('Total cost LWH: %f\n', total_cost_lh);

% Function to calculate metrics
function metrics = calculate_metrics(data)
    energy = trapz(data.Time, data.Power);
    std_dev = std(data.Power);
    max_power = max(data.Power);
    min_power = min(data.Power);
    mean_power = mean(data.Power);
    median_power = median(data.Power);
    metrics = struct('Total_Energy_Joules', energy, 'Standard_Deviation', std_dev, 'Maximum', max_power, 'Minimum', min_power, 'Average', mean_power, 'Median', median_power);
end
