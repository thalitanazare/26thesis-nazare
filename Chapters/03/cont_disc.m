clear; clc; close all;

%% Signal parameters
f1 = 0.35;      % frequency component [Hz]
f2 = 1.10;      % frequency component [Hz]
f3 = 2.20;      % frequency component [Hz]

phi2 = 0.8;     % phase [rad]
phi3 = 1.6;     % phase [rad]

Ts = 0.2;      % sampling period [s]
tf = 12;        % final time [s]

%% Time vectors
t  = linspace(0, tf, 4000);   % continuous-time reference
tk = 0:Ts:tf;                 % discrete-time instants

%% Multi-frequency signal
x_base = 0.65*sin(2*pi*f1.*t) + ...
         0.40*sin(2*pi*f2.*t + phi2) + ...
         0.25*sin(2*pi*f3.*t + phi3);

%% Smooth noise contribution
rng(10)
noise_raw = randn(size(t));
noise_smooth = smoothdata(noise_raw, 'gaussian', 90);
noise_smooth = noise_smooth ./ max(abs(noise_smooth));

%% Continuous-time signal
x_cont = x_base + 0.14*noise_smooth;

%% Discrete-time representation by sampling
% x_k = x(k Ts)
x_disc = interp1(t, x_cont, tk, 'linear');

%% Visual settings
width = 2;
markerSize = 3;

T = pink(20);
colors1 = [T(9,:); T(6,:); T(2,:)];

fontName   = 'Times New Roman';
fontAxes   = 13;
fontLabels = 13;
fontTitle  = 11;
fontLegend = 11;

%% Figure
figure
set(gcf, 'Units', 'centimeters', 'Position', [5 3 18 6.5])
set(gcf, 'Color', 'w')
set(gcf, 'Renderer', 'Painters')

%% (a) Continuous-time signal
subplot(1,2,1)
hold on

plot(t, x_cont, ...
    'LineWidth', width, ...
    'Color', colors1(3,:))

h1 = xlabel('$t$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels);

h2 = ylabel('$x(t)$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels);

title('(a) Continuous-time signal.', ...
    'FontName', fontName, ...
    'FontSize', fontTitle, ...
    'FontWeight', 'normal')

% legend({'Continuous-time signal'}, ...
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

xlim([0 tf])
ylim([-1.4 1.4])

%% (b) Discrete-time signal
subplot(1,2,2)
hold on

stem(tk, x_disc, ...
    'filled', ...
    'LineWidth', 1.3, ...
    'Color', colors1(3,:), ...
    'MarkerSize', 2.3, ...
    'MarkerFaceColor', colors1(3,:), ...
    'MarkerEdgeColor', colors1(3,:))

h1 = xlabel('$k$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels);

h2 = ylabel('$x_k$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels);

title('(b) Discrete-time signal.', ...
    'FontName', fontName, ...
    'FontSize', fontTitle, ...
    'FontWeight', 'normal')

% legend({'Discrete-time samples'}, ...
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

xlim([0 tf])
ylim([-1.4 1.4])

% exportgraphics(gcf,'continuous_discrete_multifrequency_signal.pdf','ContentType','vector')