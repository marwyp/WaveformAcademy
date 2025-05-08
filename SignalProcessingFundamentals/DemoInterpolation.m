clearvars; close all;

%% Parameters
interp_method = 'spline';
interp_factor = 20;

%% Sine Wave 1D Interpolation
time = 0 : 2 : 23;
temperature = 15 + 8 * sin(2 * pi * time / 24 - pi/2) +...
    randn(size(time)) * 0.5;
time_interp = time(1) : 2 / interp_factor : time(end);
temperature_interp = interp1(time, temperature, time_interp, interp_method);

figure('Color', 'white', 'Position', [100, 100, 800, 500]);
hold on;
plot(time_interp, temperature_interp, ...
    '-',...
    'LineWidth', 2.5, ...
    'Color', '#FF5757');
plot(time, temperature, ...
    'o',...
    'LineWidth', 2.5, ...
    'Color', '#FF5757', ... % Orange-red color
    'MarkerSize', 8, ...
    'MarkerFaceColor', '#FF5757', ...
    'MarkerEdgeColor', 'white');
hold off;
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3, 'LineWidth', 1.2);
xlim([0 23]); xticks(0:2:23);
ylim([6, 24]); yticks(6:2:24);
xlabel('Time (hours)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Temperature (°C)', 'FontSize', 12, 'FontWeight', 'bold');

%% Image 2D Interpolation
img = imread('cameraman.tif');
img = img(1 : 2 : end, 1 : 2 : end);

[X, Y] = meshgrid(1 : size(img, 2), 1 : size(img, 1));
[Xq, Yq] = meshgrid(1 : 1 / interp_factor : size(img, 2), ...
    1 : 1 / interp_factor : size(img, 1));
img_interp = uint8(interp2(X, Y, double(img), Xq, Yq, interp_method));

figure;
imagesc(img);
colormap('gray');
axis off;
set(gca, 'Position', [0 0 1 1]);

figure;
imagesc(img_interp);
colormap('gray');
axis off;
set(gca, 'Position', [0 0 1 1]);