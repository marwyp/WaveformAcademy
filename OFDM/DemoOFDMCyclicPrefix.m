clearvars; close all;

%% Parameters
n_subcarriers = 128;
n_symbols = 7;
cp_length = 12;
scs = 15e3;
fs = n_subcarriers * scs;
qam_order = 4;

%% OFDM Grid Generation & Modulation
qam_symbols = randi(qam_order, n_subcarriers, n_symbols) - 1;
ofdm_grid = qammod(qam_symbols, qam_order, 'gray', 'UnitAveragePower', true);
ofdm_signal = ofdmmod(ofdm_grid, n_subcarriers, cp_length);

figure;
plot(real(ofdm_grid), imag(ofdm_grid), '.', ...
    'MarkerSize', 30, 'Color', '#FF5757');
axlim = (max(max(abs(ofdm_grid)))) + 0.05;
ylim([-axlim, axlim]); xlim([-axlim, axlim]); axis square;
xlabel('In-phase'); ylabel('Quadrature');

%% Multipath Propagation (ISI)
ofdm_signal_isi = ofdm_signal + 0.5 * circshift(ofdm_signal, 10);

%% OFDM Demodulation
ofdm_grid_rec = ofdmdemod(ofdm_signal_isi, n_subcarriers, cp_length);

colors = parula(qam_order); colors = colors(randperm(qam_order), :);
figure;
hold on;
for i = 1 : length(ofdm_grid_rec(:))
    plot(real(ofdm_grid_rec(i)), imag(ofdm_grid_rec(i)), ...
        '.', 'Color', colors(qam_symbols(i) + 1, :), 'MarkerSize', 30);
end
hold off;
axlim = max(max(abs(ofdm_grid_rec))) + 0.05;
ylim([-axlim, axlim]); xlim([-axlim, axlim]); axis square;
xlabel('In-phase'); ylabel('Quadrature');

%% Symbol Error Rate Calculation
qam_symbols_rec = qamdemod(ofdm_grid_rec, qam_order, ...
    'gray', 'UnitAveragePower', true);
n_errors = sum(sum(qam_symbols_rec ~= qam_symbols));
SER = n_errors / (n_subcarriers * n_symbols);
disp("Symbol Error Rate: " + SER);
