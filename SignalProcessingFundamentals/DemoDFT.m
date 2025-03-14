clearvars; close all;

%% Parameters
fs = 100;       % sampling frequency in Hz
fc = 5;         % frequency of time domain signal in Hz

%% DFT Analysis Matrix
k = (0 : fs - 1).';
n = (0 : fs - 1);
dft_matrix = exp(-2i * pi / fs * k * n);

colors = ["#233ce6", "#ff5757", "#00bf63", "#0cc0df", "#ff941d"];
figure;
hold on;
for i = 1 : 4
    plot(real(dft_matrix(i, :)), "-", 'Color', colors(i), 'LineWidth', 2);
    xlabel("Samples [n]", 'FontSize', 15);
    ylabel("Amplitude", 'FontSize', 15);
end
hold off;

figure;
hold on;
for i = 1 : 4
    plot(imag(dft_matrix(i, :)), "-", 'Color', colors(i), 'LineWidth', 2);
    xlabel("Samples [n]", 'FontSize', 15);
    ylabel("Amplitude", 'FontSize', 15);
end
hold off;

%% Time-domain Signal
time = (0 : fs - 1) / fs;
x_signal = sin(2 * pi * fc * time).';

figure;
plot(time, x_signal, 'Color', colors(1), 'LineWidth', 2)
xlabel("Time [s]", 'FontSize', 15);
ylabel("Amplitude", 'FontSize', 15);

%% Signal Spectrum
x_spectrum = dft_matrix * x_signal;
x_spectrum_fft = fft(x_signal);
dft_error = max(max(abs(x_spectrum_fft - x_spectrum)));
disp("DFT error: " + dft_error);

freq = k - fs / 2;
figure;
plot(freq, fftshift(abs(x_spectrum)), 'Color', colors(2), 'LineWidth', 2);
xlabel("Frequency [Hz]", 'FontSize', 15);
ylabel("Magnitude", 'FontSize', 15);

%% Signal Reconstruction
idft_matrix = dft_matrix' / fs;

x_signal_rec = idft_matrix * x_spectrum;
rec_error = max(abs(x_signal_rec - x_signal));
disp("Reconstruction error: " + rec_error);

figure;
plot(time, real(x_signal_rec), 'Color', colors(3), 'LineWidth', 2)
xlabel("Time [s]", 'FontSize', 15);
ylabel("Amplitude", 'FontSize', 15);
