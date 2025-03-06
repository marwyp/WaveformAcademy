clearvars; close all;

%% parameters
fs = 1000;            % sampling frequency in Hz
N = 1000;             % number of carriers
c_used = 5:8;         % used subcarriers (1 - N/2)
fft_pad = 20;         % padd signal with 0 before fft
scs = fs/N;           % subcarrier spacing in Hz

%% signal generation
time = (0 : fs - 1) / fs;
x = zeros(N, fs);
for n = c_used
    x(n, :) = sin(2 * pi * n * scs * time);
end

figure
hold on;
for n = 1 : N / 2
    plot(time, x(n, :), 'LineWidth', 1.5);
end
hold off;
xlabel("Time [s]", 'FontSize', 15);
ylabel("Amplitude", 'FontSize', 15);

%% freq domain
X = zeros(N, fs * fft_pad);
for n = 1 : N
    X(n, :) = fft(x(n, :), fs * fft_pad) / fs * 2;
end
X = X(:, 1 : fs * fft_pad / 2);
freq = (0 : fs * fft_pad / 2 - 1) / fft_pad;

figure;
hold on;
for n = 1 : N / 2
    plot(freq, abs(X(n, :)), 'LineWidth', 1.5);
end
hold off;
xlim([c_used(1) - 2 c_used(length(c_used)) + 2] * scs);
xlabel("Frequency [Hz]", 'FontSize', 15);

%% Signal combined
x = sum(x);

figure;
plot(time, x, 'LineWidth', 1.5);
xlabel("Time [s]", 'FontSize', 15);
ylabel("Amplitude", 'FontSize', 15);

%% Signal combined freq domain
X = fft(x, fs * fft_pad) / fs;
X = X(1 : fs / 2 * fft_pad);
freq = (0 : fs * fft_pad / 2 - 1) / fft_pad;

figure;
plot(freq, abs(X), 'LineWidth', 1.5);
xlim([c_used(1) - 2 c_used(length(c_used)) + 2] * scs);
xlabel("Frequency [Hz]", 'FontSize', 15);
