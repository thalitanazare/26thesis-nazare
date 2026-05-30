% Lorenz chaotic attractor
% System:
% dx/dt = sigma*(y - x)
% dy/dt = x*(rho - z) - y
% dz/dt = x*y - beta*z

clear; clc; close all;

%% Lorenz system parameters
sigma = 10;
rho   = 28;
beta  = 8/3;

%% Simulation settings
t0 = 0;
tf = 50;
tspan = [t0 tf];

% Initial condition
x0 = [1; 1; 1];

%% Visual settings
width = 2;
markerSize = 3;

T = pink(20);
colors1 = [T(9,:); T(6,:); T(2,:)];

fontName = 'SansSerif';
fontAxes   = 13;
fontLabels = 13;
fontTitle  = 11;
fontLegend = 11;

%% Lorenz system definition
lorenzSystem = @(t, x) [
    sigma * (x(2) - x(1));
    x(1) * (rho - x(3)) - x(2);
    x(1) * x(2) - beta * x(3)
];

%% Numerical integration
[t, x] = ode45(lorenzSystem, tspan, x0);

%% Figure
figure
set(gcf, 'Units', 'centimeters', 'Position', [5 3 18 6.5])
set(gcf, 'Color', 'w')
set(gcf, 'Renderer', 'Painters')

hold on

plot3(x(:,1), x(:,2), x(:,3), ...
    'LineWidth', 1, ...
    'Color', colors1(2,:))

h1 = xlabel('$x(t)$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels);

h2 = ylabel('$y(t)$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels);

h3 = zlabel('$z(t)$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels);

% title('Lorenz Chaotic Attractor', ...
%     'FontName', fontName, ...
%     'FontSize', fontTitle, ...
%     'FontWeight', 'normal')

% legend({'Lorenz trajectory'}, ...
%     'FontName', fontName, ...
%     'FontSize', fontLegend, ...
%     'Location', 'northeast', ...
%     'EdgeColor', 'none')

ax = gca;
set(ax, ...
    'LineWidth', 1.5, ...
    'FontSize', fontAxes, ...
    'FontName', fontName)

grid on
box off

axis tight
view(45, 25)