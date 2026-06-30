% Configurações iniciais
tempo_alvo_segundos = 72 * 3600;
%salvar_cada = 1e10;
relatorio_cada = 1800;  % em segundos -- meia hora

% Valores iniciais
x0=[0.1000057140259469; 0.10000428889054676; 0.10000578091301135; 0.1000020609823214; 0.10000813321251358];
x=x0;
%x_result = [];  % onde serão salvos os x(i) a cada 1e10

i = 6;
contador_cifras = 5.18746e+10;
ultimo_relatorio = 0;
%tempo_ultima_reinicializacao = 0;


logID = fopen('progresso_simulacao2.txt','w');
fprintf(logID, 'Horas(s)\tCrifras Acumuladas\n');

tic;
while toc < tempo_alvo_segundos
    % Equação do modelo
    x(i)=0.1972*10*x(i-1) - 0.104*10*x(i-2) ...
                  + 0.7456e-4*x(i-4)*x(i-2)^3*x(i-1) ...
                  - 0.2053e-4*x(i-5)*x(i-4)^4 ...
                  - 0.285e-4*x(i-5)*x(i-1)^4 ...
                  + 0.2484e-4*x(i-3)^2*x(i-2)^3 ...
                  + 0.1238e-2*x(i-2)*x(i-1)^2 ...
                  + 0.4353e-4*x(i-5)^4 ...
                  + 0.2258e-2*x(i-5)*x(i-2)*x(i-1)^2 ...
                  + 0.3123e-4*x(i-4)^5 ...
                  + 0.7531e-3*x(i-1)^4 ...
                  - 0.2703e-2*x(i-3)^2*x(i-1)^2 ...
                  - 0.7807e-3*x(i-1)^3 ...
                  - 0.7077e-4*x(i-3)^2*x(i-2)^2*x(i-1) ...
                  - 0.3304e-3*x(i-3)*x(i-2)^3 ...
                  - 0.8847e-2*x(i-5)*x(i-1) ...
                  + 0.7631e-2*x(i-4)*x(i-1) ...
                  - 0.3870e-4*x(i-5)^3*x(i-1)^2 ...
                  + 0.4676e-3*x(i-3)^3*x(i-1);

    contador_cifras = contador_cifras + 1;
    i = i+1;


    % Mostrar progresso a cada hora
    tempo_atual = toc;
    if tempo_atual - ultimo_relatorio >= relatorio_cada
        horas = (tempo_atual / 3600) + 29.94;
        fprintf('Tempo: %.2f h | Cifras: %.5e\n', horas, contador_cifras);
        fprintf(logID,'%.2f\t%.5e\n',horas,contador_cifras);
        
        x =x0;
        i = 6;

        ultimo_relatorio=tempo_atual;
    end

end
fclose(logID);


fprintf('\nSimulação finalizada!\nTempo total: %.2f horas\nCifras geradas: %.0f\n', ...
        toc/3600, contador_cifras);
