clearvars; close all;

%% Parameters
n_subcarriers = 128;
n_symbols = 20;
scs = 15e3;
data_order = 256;
pilot_order = 4;
cp_length = 12;

fs = n_subcarriers * scs;

%% OFDM Grid Generation & Modulation
data_symbols = randi(data_order, n_subcarriers, n_symbols) - 1;
data_qam_states = qammod(data_symbols, data_order, 'gray', ...
    'UnitAveragePower', true);
pilot_symbols = randi(pilot_order, n_subcarriers / 4, n_symbols / 4) - 1;
pilot_qam_states = qammod(pilot_symbols, pilot_order, "gray", ...
    "UnitAveragePower", true);

pilot_locations = false(n_subcarriers, n_symbols);
pilot_locations(1 : 4 : end, 1 : 4 : end) = true;
data_locations = true(n_subcarriers, n_symbols);
data_locations(pilot_locations) = false;

ofdm_grid = zeros(n_subcarriers, n_symbols);
ofdm_grid(data_locations) = data_qam_states(data_locations);
ofdm_grid(pilot_locations) = pilot_qam_states;

tx_waveform = ofdmmod(ofdm_grid, n_subcarriers, cp_length);

figure;
plot(real(ofdm_grid(data_locations)), imag(ofdm_grid(data_locations)), ...
    'o', 'Color', '#233ce6');
axlim = max(max(abs(ofdm_grid(data_locations)))) + 0.05;
ylim([-axlim, axlim]); xlim([-axlim axlim]); axis square;
xlabel("In-phase"); ylabel("Quadrature");

figure;
plot(real(ofdm_grid(pilot_locations)), imag(ofdm_grid(pilot_locations)), ...
    'o', 'Color', '#233ce6');
axlim = max(max(abs(ofdm_grid(pilot_locations)))) + 0.05;
ylim([-axlim, axlim]); xlim([-axlim axlim]); axis square;
xlabel("In-phase"); ylabel("Quadrature");

%% Multipath Propagation
time = (0 : length(tx_waveform) - 1) / fs;
rx_waveform = tx_waveform ...
    + 0.25 * circshift(tx_waveform, 10) .* exp(2 * pi * 100 * time.');

%% OFDM Demodulation
ofdm_grid_rec = ofdmdemod(rx_waveform, n_subcarriers, cp_length);

figure;
plot(real(ofdm_grid_rec(data_locations)), ...
    imag(ofdm_grid_rec(data_locations)), 'o', 'Color', '#233ce6');
axlim = max(max(abs(ofdm_grid_rec))) + 0.05;
ylim([-axlim, axlim]); xlim([-axlim, axlim]); axis square;
xlabel("In-phase"); ylabel("Quadrature");

%% Channel Estimation
pilot_qam_states_rec = ofdm_grid_rec(pilot_locations);
hest = reshape(pilot_qam_states_rec, n_subcarriers / 4, n_symbols / 4) ...
    ./ pilot_qam_states;
[X, Y] = meshgrid(1 : 4 : n_symbols, 1 : 4 : n_subcarriers);
[Xq, Yq] = meshgrid(1 : n_symbols, 1 : n_subcarriers);
hest_interp = interp2(X, Y, hest, Xq, Yq, "spline");

ofdm_grid_rec = ofdm_grid_rec ./ hest_interp;

figure;
plot(real(ofdm_grid_rec(data_locations)), ...
    imag(ofdm_grid_rec(data_locations)), 'o', 'Color', '#233ce6');
axlim = max(max(abs(ofdm_grid_rec))) + 0.05;
ylim([-axlim, axlim]); xlim([-axlim, axlim]); axis square;
xlabel("In-phase"); ylabel("Quadrature");

%% Symbol Error Rate Calculation
data_symbols_rec = qamdemod(ofdm_grid_rec(data_locations), data_order, ...
    "gray", "UnitAveragePower", true);
n_errors = sum(sum(data_symbols_rec ~= data_symbols(data_locations)));
SER = n_errors / length(data_symbols_rec);
disp("Symbol Error Rate: " + SER);