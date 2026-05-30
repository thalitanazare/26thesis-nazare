clear; clc; close all;

% Frequency vector [rad/s]
w = linspace(0.01, 2.0, 2000);

% Gravity
g = 9.81;

% Visual settings
width = 2;
H = bone(20);
T = pink(20);

figure
set(gcf, 'Units', 'centimeters', 'Position', [5 3 18 6.5])
set(gcf, 'Color', 'w')
set(gcf, 'renderer', 'Painters')

%% (a) Varying Tp
subplot(1,3,1)
hold on

Hs = 1.2;
gamma = 3.3;
Tp_values = [8 10 12];
colors1 = [T(9,:); T(6,:); T(2,:)];

for i = 1:length(Tp_values)
    S = jonswap_spectrum(w, Hs, Tp_values(i), gamma, g);
    plot(w, S, 'LineWidth', width, 'Color', colors1(i,:))
end

h1 = xlabel('$\omega\;[\mathrm{rad/s}]$');
h2 = ylabel('$S_{\eta\eta}(\omega)\;[\mathrm{m^2 s}]$');
title('(a) $H_s=1.2$ m and $\gamma=3.3$.', 'Interpreter', 'latex')
legend({'$T_p=8$ s','$T_p=10$ s','$T_p=12$ s'}, ...
    'Interpreter', 'latex', 'Location', 'northeast','EdgeColor', 'none')

ax = gca;
set(ax,'LineWidth',2,'FontSize',11)
set([h1,h2],'Interpreter','latex')
grid on
box off

%% (b) Varying Hs
subplot(1,3,2)
hold on

Tp = 10;
gamma = 3.3;
Hs_values = [1.2 3 6.2];
colors2 = [T(6,:); T(12,:); T(18,:)];

for i = 1:length(Hs_values)
    S = jonswap_spectrum(w, Hs_values(i), Tp, gamma, g);
    plot(w, S, 'LineWidth', width, 'Color', colors1(i,:))
end

h1 = xlabel('$\omega\;[\mathrm{rad/s}]$');
h2 = ylabel('$S_{\eta\eta}(\omega)\;[\mathrm{m^2 s}]$');
title('(b) $T_p=10$ s and $\gamma=3.3$.', 'Interpreter', 'latex')
legend({'$H_s=1.2$ m','$H_s=5$ m','$H_s=6.2$ m'}, ...
    'Interpreter', 'latex', 'Location', 'northeast','EdgeColor', 'none')

ax = gca;
set(ax,'LineWidth',2,'FontSize',11)
set([h1,h2],'Interpreter','latex')
grid on
box off

%% (c) Varying gamma
subplot(1,3,3)
hold on

Hs = 1.2;
Tp = 8;
gamma_values = [1 3.3 6];
colors3 = [0.65 0.65 0.65; 0.35 0.35 0.35; 0 0 0];

for i = 1:length(gamma_values)
    S = jonswap_spectrum(w, Hs, Tp, gamma_values(i), g);
    plot(w, S, 'LineWidth', width, 'Color', colors1(i,:))
end

h1 = xlabel('$\omega\;[\mathrm{rad/s}]$');
h2 = ylabel('$S_{\eta\eta}(\omega)\;[\mathrm{m^2 s}]$');
title('(c) $T_p=8$ s and $H_s=1.2$ m.', 'Interpreter', 'latex')
legend({'$\gamma=1$','$\gamma=3.3$','$\gamma=6$'}, ...
    'Interpreter', 'latex', 'Location', 'northeast','EdgeColor', 'none')

ax = gca;
set(ax,'LineWidth',2,'FontSize',11)
set([h1,h2],'Interpreter','latex')
grid on
box off

% exportgraphics(gcf,'jonswap_examples.pdf','ContentType','vector')

%% Local function
function S = jonswap_spectrum(w, Hs, Tp, gamma, g)

    wp = 2*pi/Tp;

    sigma = 0.07 * ones(size(w));
    sigma(w > wp) = 0.09;

    alpha = 0.076 * (Hs^2 * wp^4 / g^2)^0.22;

    r = exp(-((w - wp).^2) ./ (2 * sigma.^2 * wp^2));

    S = alpha * g^2 .* w.^(-5) .* exp(-(5/4) * (wp ./ w).^4) .* gamma.^r;

    S(w <= 0) = 0;
end