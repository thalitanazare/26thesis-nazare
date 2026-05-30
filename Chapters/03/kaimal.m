clear; clc; close all;

%% Frequency vector [Hz]
f = linspace(0.001, 1.0, 2000);

%% Visual settings
width = 2;
T = pink(20);
colors1 = [T(9,:); T(6,:); T(2,:)];

%% Kaimal spectrum function
% S(f) = (4 sigma1^2 Lt / vmean) * (1 + 6 f Lt / vmean)^(-5/3)
kaimal = @(f, sigma1, Lt, vmean) ...
    (4 .* sigma1.^2 .* Lt ./ vmean) .* (1 + 6 .* f .* Lt ./ vmean).^(-5/3);

%% Figure
figure
set(gcf, 'Units', 'centimeters', 'Position', [5 3 18 6.5])
set(gcf, 'Color', 'w')
set(gcf, 'renderer', 'Painters')

%% (a) Varying v_mean
subplot(1,3,1)
hold on

Lt = 340;
TI = 0.10;
vmean_values = [8 12 18];

for i = 1:length(vmean_values)
    vmean = vmean_values(i);
    sigma1 = TI * vmean;
    S = kaimal(f, sigma1, Lt, vmean);
    plot(f, S, 'LineWidth', width, 'Color', colors1(i,:))
end

h1 = xlabel('$f\;[\mathrm{Hz}]$');
h2 = ylabel('$S_1(f)\;[\mathrm{m^2/s}]$');
title('(a) $TI=10\%$ and $L_t=340$ m.', 'Interpreter', 'latex')
legend({'$v_{mean}=8$ m/s','$v_{mean}=12$ m/s','$v_{mean}=18$ m/s'}, ...
    'Interpreter', 'latex', 'Location', 'northeast', 'EdgeColor', 'none')

ax = gca;
set(ax,'LineWidth',2,'FontSize',11)
set([h1,h2],'Interpreter','latex')
grid off
box off

%% (b) Varying sigma1 through turbulence intensity
subplot(1,3,2)
hold on

Lt = 340;
vmean = 12;
TI_values = [0.05 0.10 0.15];

for i = 1:length(TI_values)
    sigma1 = TI_values(i) * vmean;
    S = kaimal(f, sigma1, Lt, vmean);
    plot(f, S, 'LineWidth', width, 'Color', colors1(i,:))
end

h1 = xlabel('$f\;[\mathrm{Hz}]$');
h2 = ylabel('$S_1(f)\;[\mathrm{m^2/s}]$');
title('(b) $v_{mean}=12$ m/s and $L_t=340$ m.', 'Interpreter', 'latex')
legend({'$TI=5\%$','$TI=10\%$','$TI=15\%$'}, ...
    'Interpreter', 'latex', 'Location', 'northeast', 'EdgeColor', 'none')

ax = gca;
set(ax,'LineWidth',2,'FontSize',11)
set([h1,h2],'Interpreter','latex')
grid off
box off

%% (c) Varying Lt
subplot(1,3,3)
hold on

vmean = 12;
TI = 0.10;
sigma1 = TI * vmean;
Lt_values = [100 200 340];

for i = 1:length(Lt_values)
    S = kaimal(f, sigma1, Lt_values(i), vmean);
    plot(f, S, 'LineWidth', width, 'Color', colors1(i,:))
end

h1 = xlabel('$f\;[\mathrm{Hz}]$');
h2 = ylabel('$S_1(f)\;[\mathrm{m^2/s}]$');
title('(c) $v_{mean}=12$ m/s and $TI=10\%$.', 'Interpreter', 'latex')
legend({'$L_t=100$ m','$L_t=200$ m','$L_t=340$ m'}, ...
    'Interpreter', 'latex', 'Location', 'northeast', 'EdgeColor', 'none')

ax = gca;
set(ax,'LineWidth',2,'FontSize',11)
set([h1,h2],'Interpreter','latex')
grid off
box off

% exportgraphics(gcf,'kaimal_examples.pdf','ContentType','vector')