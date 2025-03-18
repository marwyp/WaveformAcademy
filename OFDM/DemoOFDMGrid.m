clearvars; close all;

%% Parameters
n_subcarriers = 128;
n_symbols = 7;
scs = 15e3;
fs = n_subcarriers * scs;
qam_order = 16;

%% OFDM Grid
qam_symbols = randi(qam_order, n_subcarriers, n_symbols) - 1;
ofdm_grid = qammod(qam_symbols, qam_order, 'gray', ...
    'UnitAveragePower', true);

%% Constellation Plot
figure;
plot(real(ofdm_grid), imag(ofdm_grid), '.', ...
    'MarkerSize', 30, 'Color', '#FF5757');
axlim = max(max(abs(ofdm_grid))) + 0.05;
ylim([-axlim, axlim]); xlim([-axlim, axlim]); axis square;
xlabel('In-phase'); ylabel("Quadrature");

%% OFDM Modulation Using Transformation Matrix
k = (0 : n_subcarriers - 1).';
n = (0 : n_subcarriers - 1);
dft_matrix = exp(-2i * pi / n_subcarriers * k * n);
idft_matrix = dft_matrix' / n_subcarriers;

ofdm_grid_shifted = [
    ofdm_grid(n_subcarriers / 2 + 1 : end, :); ...
    ofdm_grid(1 : n_subcarriers / 2, :)];
ofdm_signal_idft = idft_matrix * ofdm_grid_shifted;
ofdm_signal_idft = reshape(ofdm_signal_idft, [], 1);

%% OFDM Modulation Using IFFT
ofdm_signal_ifft = ifft(ifftshift(ofdm_grid, 1));
ofdm_signal_ifft = reshape(ofdm_signal_ifft, [], 1);
error_idft_ifft = max(abs(ofdm_signal_ifft - ofdm_signal_idft));
disp("IDFT vs IFFT error: " + error_idft_ifft);

%% OFDM Modulation Using ofdmmod Function
ofdm_signal_ofdmmod = ofdmmod(ofdm_grid, n_subcarriers, 0);
error_ifft_ofdmmod = max(abs(ofdm_signal_ofdmmod - ofdm_signal_ifft));
disp("IFFT vs OFDMMOD error: " + error_ifft_ofdmmod);

%% OFDM Demodulation Using ofdmdemod Function
ofdm_grid_reconstructed = ofdmdemod(ofdm_signal_ofdmmod, n_subcarriers, 0);
error_reconstruction = max(max(abs(ofdm_grid_reconstructed - ofdm_grid)));
disp("Reconstruction error: " + error_reconstruction);
