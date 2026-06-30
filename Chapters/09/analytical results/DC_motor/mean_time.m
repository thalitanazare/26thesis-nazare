clear all
close all
clc

% Carregar os dados de entrada (u_cc.csv) e saída do sistema físico (y_cc.csv)
u_cc = csvread('u_cc.csv');
y_cc = csvread('y_cc.csv');

% Decimação dos dados
d = 500;
u_cc = downsample(u_cc, d);
y_cc = downsample(y_cc, d);

% Novo tamanho dos dados após decimação
N = length(u_cc);

% Número de iterações para calcular o tempo médio
num_iter = 50;
normal_time = zeros(1, num_iter);
horner_time = zeros(1, num_iter);

% Loop para calcular o tempo médio
for iter = 1:num_iter
    % Modelo original (sem Horner)
    y_original = zeros(N, 1);
    tic; % Início da contagem de tempo para o modelo original
    for k = 3:N
        y_original(k) = 1.7813 * y_original(k-1) - 0.7962 * y_original(k-2) ...
            + 0.0339 * u_cc(k-1) - 0.1597 * u_cc(k-1) * y_original(k-1) ...
            + 0.0338 * u_cc(k-2) + 0.1297 * u_cc(k-1) * y_original(k-2) ...
            - 0.1396 * u_cc(k-2) * y_original(k-1) ...
            + 0.1086 * u_cc(k-2) * y_original(k-2) ...
            + 0.0085 * y_original(k-2)^2;
    end
    normal_time(iter) = toc; % Tempo total para o modelo original

    % Modelo com Horner
    y_horner = zeros(N, 1);
    tic; % Início da contagem de tempo para o modelo com Horner
    for k = 3:N
        a0 = 1.7813 * y_horner(k-1) + 0.0339 * u_cc(k-1) - 0.1597 * u_cc(k-1) * y_horner(k-1) ...
            + 0.0338 * u_cc(k-2) - 0.1396 * u_cc(k-2) * y_horner(k-1);
        a1 = -0.7962 + 0.1297 * u_cc(k-1) + 0.1086 * u_cc(k-2);
        y_horner(k) = a0 + y_horner(k-2) * (a1 + y_horner(k-2) * 0.0085);
    end
    horner_time(iter) = toc; % Tempo total para o modelo com Horner
end

% Calcular média e desvio padrão dos tempos
normal_mean = mean(normal_time);
normal_std = std(normal_time);
horner_mean = mean(horner_time);
horner_std = std(horner_time);

% Exibir resultados
fprintf('Modelo Original (Sem Horner): \n');
fprintf('Tempo médio: %.15f segundos\n', normal_mean);
fprintf('Desvio padrão: %.15f segundos\n\n', normal_std);

fprintf('Modelo com Horner: \n');
fprintf('Tempo médio: %.15f segundos\n', horner_mean);
fprintf('Desvio padrão: %.15f segundos\n\n', horner_std);
