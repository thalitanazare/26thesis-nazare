%% Logistic map - MATLAB version
clear; close all; clc

%% Visual settings
width = 2;
markerSize = 3;

T = pink(20);
palette = [T(9,:); T(6,:); T(2,:)];

% Automatically identify darkest, medium, and lightest colors
brightness = sum(palette, 2);
[~, order] = sort(brightness, 'ascend');

darkestColor = palette(order(1), :);
mediumColor  = palette(order(2), :);
lightestColor = palette(order(3), :);

fontName = 'SansSerif';
fontAxes   = 13;
fontLabels = 13;
fontTitle  = 11;
fontLegend = 11;

%% Parameters
r  = 3.9;      % bifurcation parameter
x0 = 0.1;      % initial condition
y0 = x0;       % same initial condition

N = 200;

%% Preallocation
x = zeros(N+1,1);
y = zeros(N+1,1);

x(1) = x0;
y(1) = y0;

%% Logistic maps
for k = 1:N
    x(k+1) = r*x(k)*(1 - x(k));          % F
end

for k = 1:N
    y(k+1) = r*(y(k)*(1 - y(k)));        % G
end

%% LBE and LLE
startIndex = 1;

LBE = abs(y(startIndex:N) - x(startIndex:N))/2;
graf_LBE = log10(LBE + eps);   % eps avoids log10(0)

vec1 = 4;
vec2 = 80;

% Python slice graf_LBE[vec1:vec2] corresponds to indices 4:79
% MATLAB equivalent:
idxFit = vec1+1:vec2;

vecN = linspace(vec1, vec2, vec2 - vec1);

LLE = polyfit(vecN(:), graf_LBE(idxFit), 1);

LLE1 = LLE(1);
LLE2 = LLE(2);

Ts = fix(abs((log10(1/2) + 16)/LLE(1)));

%% Figure 1 - Logistic map sequences
figure
set(gcf, 'Units', 'centimeters', 'Position', [5 3 18 6.5])
set(gcf, 'Color', 'w')
set(gcf, 'Renderer', 'Painters')

hold on

% F uses the darkest color
plot(0:N, x, ...
    'LineWidth', 1.5, ...
    'Marker', 'o', ...
    'MarkerSize', 3.5, ...
    'Color', 'k')

% G uses another palette color
plot(0:N, y, ...
    'LineWidth', 1.5, ...
    'Marker', 'x', ...
    'MarkerSize', 3.5, ...
    'Color',T(9,:))

xline(40, ...
    'LineStyle', '-', ...
    'LineWidth', 1.5, ...
    'Color', 'k')

yline(-0.15, ...
    'LineStyle', '-', ...
    'LineWidth', 1.5, ...
    'Color', 'k')

xlabel('$N$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels)

ylabel('$F(x_n),\ G(x_n)$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels)

ax = gca;
set(ax, ...
    'LineWidth', 1.5, ...
    'FontSize', fontAxes, ...
    'FontName', fontName)

axis([40 100 -0.15 1.15])
grid on
box off

exportgraphics(gcf, 'mapalogEX.pdf', 'ContentType', 'vector')

%% Figure 2 - LBE with linear fit
figure
set(gcf, 'Units', 'centimeters', 'Position', [5 3 18 10])
set(gcf, 'Color', 'w')
set(gcf, 'Renderer', 'Painters')

hold on

% log curve uses the darkest color
plot(0:length(graf_LBE)-1, graf_LBE, ...
    'LineWidth', 1.5, ...
    'Marker', 'o', ...
    'MarkerSize', 2, ...
    'Color', 'k')

plot(vecN, polyval(LLE, vecN), ...
    'LineWidth', 3, ...
    'Color', T(7,:))

xline(0, ...
    'LineStyle', '-', ...
    'LineWidth', 1.5, ...
    'Color', 'k')

yline(-17, ...
    'LineStyle', '-', ...
    'LineWidth', 1.5, ...
    'Color', 'k')

text(40, -16, sprintf('%.5f n', LLE1), ...
    'FontName', fontName, ...
    'FontSize', fontLabels)

text(65, -16, sprintf('%.5f', LLE2), ...
    'FontName', fontName, ...
    'FontSize', fontLabels)

xlabel('$N$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels)

ylabel('$\log_{10}|\delta_{\alpha,n}|$', ...
    'Interpreter', 'latex', ...
    'FontName', fontName, ...
    'FontSize', fontLabels)

ax = gca;
set(ax, ...
    'LineWidth', 1.5, ...
    'FontSize', fontAxes, ...
    'FontName', fontName)

axis([0 160 -17 1])
grid on
box off

exportgraphics(gcf, 'mapalogLLE.pdf', 'ContentType', 'vector')

