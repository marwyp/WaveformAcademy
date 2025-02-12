clearvars; close all;

%% parameters
order = 16;
symorder = 'gray';

symbols = 0 : order - 1;
bits = reshape(de2bi(symbols).', [], 1);

%% QAM modulation
qam_symbols = qammod(bits, order, symorder, "InputType", "bit", "UnitAveragePower", true);
n_symbols = length(qam_symbols);

%% constellation plot
axlim = 1.2;
color = '#FF5757';
figure;
hold on;
for i = 0 : n_symbols - 1
    txt = bits(i * log2(order) + 1 : i * log2(order) + log2(order));
    txt = num2str(txt.');
    txt = strrep(txt, ' ', '');
    text(real(qam_symbols(i + 1)) - 0.1, imag(qam_symbols(i + 1)) + 0.1, txt);
end
plot(real(qam_symbols), imag(qam_symbols), '.', 'MarkerSize', 50, 'Color', color);
hold off;
ylim([-axlim, axlim]); xlim([-axlim axlim]);
set(gca, 'XAxisLocation', 'origin'); set(gca, 'YAxisLocation', 'origin');
ax = gca; ax.XAxis.LineWidth = 2; ax.YAxis.LineWidth = 2;
yticks([]); xticks([]); axis square;

%% modulated signal
sampling_frequency = 1000;
time = (0 : n_symbols * sampling_frequency - 1) / sampling_frequency;

carrier_I = cos(2 * pi * time);
carrier_Q = sin(2 * pi * time);

qam_symbols = repelem(qam_symbols, sampling_frequency).';
modulated_signal = real(qam_symbols) .* carrier_I + imag(qam_symbols) .* carrier_Q;

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
max_ticks = 16; step = length(bits) / max_ticks;
if step < 1
    ticks = 0 : length(bits);
else
    ticks = 0 : step : length(bits);
end
xticks(ticks); xlabel('bits');
ylim([-0.2, 1.2]); xlim([0, x_values(length(x_values))]);

nexttile;
plot(time, modulated_signal, 'Color', color, 'LineWidth', 2);
max_ticks = 16; step = n_symbols / max_ticks;
if step < 1
    ticks = 0 : n_symbols;
else
    ticks = 0 : step : n_symbols;
end
xticks(ticks); xlim([0, n_symbols]); xlabel('symbols');
