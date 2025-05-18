clearvars; close all;

%% Parameters
fs = 500;

time = (0 : fs - 1) / fs;
conv_len = fs * 2 - 1;
lag = (-fs + 1 : fs - 1) / fs;

%% Signals
rectangle = zeros(1, fs);
rectangle(fs / 5 + 1 : fs / 5 * 4) = 1;
sinusoid = sin(2 * pi * 4 * time);

%% Time Domain Convolution
c_matlab = conv(rectangle, sinusoid);

c_manual = zeros(size(c_matlab));
sinusoid_flipped = fliplr(sinusoid);

rectangle_padded = [zeros(1, fs - 1), rectangle, zeros(1, fs - 1)];
sinusoid_padded = [sinusoid_flipped, zeros(1, 2 * fs - 2)];
for shift = 0 : conv_len - 1
    sinusoid_shifted = circshift(sinusoid_padded, shift);
    c_manual(shift + 1) = sum(rectangle_padded .* sinusoid_shifted);
end

error = max(abs(c_manual - c_matlab));
disp("Error = " + error);

%% Frequency Domain Convolution
rect_fft = fft(rectangle, conv_len);
sin_fft = fft(sinusoid, conv_len);
c_fft = sin_fft .* rect_fft;
c_fft = ifft(c_fft);

figure;
tiledlayout(3, 1);

nexttile;
plot(lag, c_matlab);
title('Convolution using conv'); xlabel('Time lag [s]');

nexttile;
plot(lag, c_manual);
title('Convolution calculated manually'); xlabel('Time lag [s]');

nexttile;
plot(lag, c_fft);
title('Convolution using fft'); xlabel('Time lag [s]');

%% Convolution vs. Cross-correlation
c = conv(rectangle, sinusoid);
r = xcorr(rectangle, sinusoid);
r_flipped = xcorr(rectangle, sinusoid_flipped);

figure;
tiledlayout(3, 1);

nexttile;
plot(lag, c);
title('Convolution of rectangle & sinusoid'); xlabel('Time lag [s]');

nexttile;
plot(lag, r);
title('Cross-correlation of rectangle & sinusoid'); xlabel('Time lag [s]');

nexttile;
plot(lag, r_flipped);
title('Cross-correlation of rectangle & flipped sinusoid'); xlabel('Time lag [s]');

%% 2D Convolution
img = imread('astronaut.jpg');
img_gray = rgb2gray(img);
kernel = [
    -1 -1 -1
    -1  9 -1
    -1 -1 -1
];

img_conv = conv2(img_gray, kernel, 'same');

imwrite(img_conv, 'astronaut_edges.png');