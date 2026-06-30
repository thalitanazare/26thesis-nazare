% Load the data
original_data = readmatrix('cifra_original.txt', 'FileType', 'text', 'NumHeaderLines', 1);
horner_data = readmatrix('horner_progresso_simulacao.txt', 'FileType', 'text', 'NumHeaderLines', 1);

% Extract time and cipher values
time_original = original_data(:,1);
cipher_original = original_data(:,2);

time_horner = horner_data(:,1);
cipher_horner = horner_data(:,2);

% Plot the data
figure;
plot(time_original, cipher_original, 'b.-', 'DisplayName', 'Original');
hold on;
plot(time_horner, cipher_horner, 'r.-', 'DisplayName', 'Horner');
hold off;

% Axis and labels
xlabel('Time (h)', 'FontName', 'Times', 'FontSize', 18);
ylabel('Accumulated ciphers', 'FontName', 'Times', 'FontSize', 18);
legend('Location', 'northwest');
grid on;

% Set font for axes
set(gca, 'FontName', 'Times', 'FontSize', 18);

% Percentage calculation every 24 data points (i.e., every 12 hours)
step = 22;
min_len = min(length(cipher_original), length(cipher_horner));
fprintf('--- Percentage gain of Horner over Original every 12 hours (every 24 points) ---\n');

for idx = 1:step:150
    c_o = cipher_original(idx);
    c_h = cipher_horner(idx);
    t = time_original(idx); % or time_horner(idx), as they are close

    percent_gain = (c_h - c_o) / c_o * 100;
    fprintf('At t = %.2f h: Horner = %.2e, Original = %.2e, Gain = %.2f%%\n', ...
            t, c_h, c_o, percent_gain);
end
