clearvars; close all;

%% parameters
order = 8;
offset = 0;
symorder = 'gray';
% bits = [0; 1; 1; 0; 1; 0];

symbols = 0 : order - 1;
bits = reshape(de2bi(symbols).', [], 1);

%% PSK modulation
psk_symbols = pskmod(bits, order, offset, symorder, "InputType", "bit");
n_symbols = length(psk_symbols);

%% constellation plot
axlim = 1.2;
color = '#FF5757';
circle = nsidedpoly(1000, 'Center', [0, 0], 'Radius', 1);

figure;
hold on;
plot(circle, 'FaceColor','none', 'EdgeColor', color, 'LineWidth', 2);
plot(real(psk_symbols), imag(psk_symbols), ".", 'MarkerSize', 50, 'Color', color);
for i = 0 : n_symbols - 1
    txt = bits(i * log2(order) + 1 : i * log2(order) + log2(order));
    txt = num2str(txt.');
    txt = strrep(txt, ' ', '');
    text(real(psk_symbols(i + 1)) + 0.1, imag(psk_symbols(i + 1)) + 0.1, txt);
end
hold off;
ylim([-axlim axlim]); xlim([-axlim axlim]);
set(gca, 'XAxisLocation', 'origin'); set(gca, 'YAxisLocation', 'origin');
ax = gca; ax.XAxis.LineWidth = 2; ax.YAxis.LineWidth = 2;
yticks([]); xticks([]); axis square;

%% modulated signal
sampling_frequency = 1000;
time = (0 : n_symbols * sampling_frequency - 1) / sampling_frequency;

carrier_I = cos(2 * pi * time);
carrier_Q = sin(2 * pi * time);

psk_symbols = repelem(psk_symbols, sampling_frequency).';
% modulated_signal = real(psk_symbols) .* carrier;
modulated_signal = real(psk_symbols) .* carrier_I + imag(psk_symbols) .* carrier_Q;

%% signal plot
color = '#233ce6';
figure;
tiledlayout(2, 1);

nexttile;
x_values = 0 : length(bits);
x_values = repelem(x_values, 2);
x_values = x_values(2 : end - 1);
y_values = repelem(bits, 2);
plot(x_values, y_values, 'Color', color, 'LineWidth', 2);
ylim([-0.2 1.2]);
xticks(0 : length(bits)); xlabel('bits');

nexttile;
hold on;
plot(time, modulated_signal, "Color", color, "LineWidth", 2);
for i = 1 : n_symbols - 1
    plot([i, i], [-1 1], '--r', 'LineWidth', 1.5);
end
hold off;
xticks(0 : n_symbols); xlabel('symbols');


