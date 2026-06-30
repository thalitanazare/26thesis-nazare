clear all
clc

%% Data from the article
%Horner
N_test=1000; %from article
tempo_teste=0.00095; %from article
N_total = 3.527e16;
tempo_estimado = (tempo_teste / N_test) * N_total;
tempo_dias = tempo_estimado / 86400;
fprintf('HORNER Tempo estimado: %.2f dias\n', tempo_dias);
CO2_horner=6.19e-9*3.5e16; %was in ugrama.. so passing to kg
fprintf('HORNER CO2e estimado: %.2f dias\n', CO2_horner);

%Original
N_test=1000; %from article
tempo_teste=0.00136; %from article
N_total = 3.527e16;
tempo_estimado = (tempo_teste / N_test) * N_total;
tempo_dias = tempo_estimado / 86400;
fprintf('ORIGINAL Tempo estimado: %.2f dias\n', tempo_dias);
CO2_horner=8.58e-9*3.5e16;
fprintf('HORNER CO2e estimado: %.2f dias\n', CO2_horner);