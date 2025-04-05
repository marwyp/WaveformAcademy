clearvars; close all;

%% Parameters
f = 9;
fs_analog = 100e3;
fs = 10;

%% Sine Wave Generation
time_analog = (0 : fs_analog - 1) / fs_analog;
signal_analog = sin(2 * pi * f * time_analog);

figure;
tiledlayout(2, 1);
nexttile;
hold on;
plot(time_analog, signal_analog, 'Color', '#233ce6', 'LineWidth', 1.5);
ylim([-1, 1]); xlim([0, 1]);
xlabel('Time [s]'); ylabel('Amplitude');

%% Signal Discretization
time_sampled = time_analog(1 : fs_analog / fs : end);
signal_sampled = signal_analog(1 : fs_analog / fs : end);

stem(time_sampled, signal_sampled, 'Color', 'black', 'LineWidth', 1.5);
hold off;

%% Signal Spectrum
signal_analog_spectrum = fft(signal_analog);
signal_analog_spectrum = fftshift(signal_analog_spectrum) / fs_analog;
freq = (-fs_analog / 2 : fs_analog / 2 - 1);

nexttile;
stem(freq, abs(signal_analog_spectrum),...
    'Color', '#233ce6', 'LineWidth', 1.5);
ylim([0, 0.5]); xlim([-fs, fs]);
xlabel('Frequency [Hz]'); ylabel('Magnitude');

%% Signal Reconstruction Using Linear Interpolation
signal_rec_lin = interp1(time_sampled, signal_sampled, ...
    time_analog, "linear");
signal_sampled_spectrum = fftshift(fft(signal_sampled) / fs);
freq_sampled = (-fs / 2 : fs / 2 - 1);

figure;
tiledlayout(2, 1);
nexttile;
hold on;
plot(time_analog, signal_rec_lin, 'Color', '#FF5757', 'LineWidth', 1.5);
stem(time_sampled, signal_sampled, 'Color', 'black', 'LineWidth', 1.5);
hold off;
ylim([-1, 1]); xlim([0, 1]);
xlabel('Time [s]'); ylabel('Amplitude');

nexttile;
stem(freq_sampled, abs(signal_sampled_spectrum), ...
    'Color', '#FF5757', 'LineWidth', 1.5);
ylim([0, 0.5]); xlim([-fs, fs]);
xlabel('Frequency [Hz]'); ylabel('Magnitude');