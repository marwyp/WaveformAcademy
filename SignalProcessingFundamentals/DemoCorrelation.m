clearvars; close all;

%% Parameters
fs = 500;
time = (0 : fs - 1) / fs;

%% Signals
rectangle = zeros(1, fs);
rectangle(fs / 5 + 1 : fs / 5 * 4) = 1;
sinusoid = sin(2 * pi * 4 * time);
noise = randn(1, fs);

figure;
tiledlayout(3, 1);
nexttile;
plot(time, rectangle, 'Color', '#233ce6', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('Amplitude');
nexttile;
plot(time, sinusoid, 'Color', '#FF5757', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('Amplitude');
nexttile;
plot(time, noise, 'Color', 'black', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('Amplitude');

%% Autocorrelation
[rectangle_cor, lag] = xcorr(rectangle);
sinusoid_cor = xcorr(sinusoid);
noise_cor = xcorr(noise);

figure;
tiledlayout(3, 1);
nexttile;
plot(lag / fs, rectangle_cor, 'Color', '#233ce6', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('Autocorrelation');
nexttile;
plot(lag / fs, sinusoid_cor, 'Color', '#FF5757', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('Autocorrelation');
nexttile;
plot(lag / fs, noise_cor, 'Color', 'black', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('Autocorrelation');

%% Cross-correlation
delay = randi(fs / 5);
noise_delayed = circshift(noise, delay);
[cross_cor, lag] = xcorr(noise_delayed, noise);
[max_value, max_ind] = max(cross_cor);
disp("Delay original: " + delay / fs + "s");
disp("Delay found: " + lag(max_ind) / fs + "s");

figure;
plot(lag / fs, cross_cor, 'Color', 'black', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('Cross-correlation');