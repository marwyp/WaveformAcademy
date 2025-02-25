clearvars; close all;

%% parameters
mod_type = "QAM";
order = 4;

n_symbols = 1024;
symbols = randi(order, 1, n_symbols) - 1;

sampling_frequency = 100;
noise_level = 0.25;

ask_psk_or_qam = mod_type == "QAM" || mod_type == "PSK" || mod_type == "ASK";

%% digital modulation
if mod_type == "ASK"
    modulated_symbols = (symbols + 1) / order;
elseif mod_type == "PSK"
    modulated_symbols = pskmod(symbols, order);
elseif mod_type == "QAM"
    modulated_symbols = qammod(symbols, order, 'UnitAveragePower', true);
elseif mod_type == "FSK"
    modulated_signal = fskmod(symbols, order, ...
        5, sampling_frequency, sampling_frequency);
else
    error('Unsupported modulation type');
end

%% constellation diagram
if ask_psk_or_qam
    axlim = 1.2;
    color = "#FF5757";
    [symbols_unique, ia, ic] = unique(symbols);
    bits = reshape(de2bi(symbols_unique, 'left-msb').', [], 1);
    figure;
    hold on;
    for i = 0 : length(symbols_unique) - 1
        txt = bits(i * log2(order) + 1 : i * log2(order) + log2(order));
        txt = num2str(txt.');
        txt = strrep(txt, ' ', '');
        text(real(modulated_symbols(ia(i + 1))) - 0.1, imag(modulated_symbols(ia(i + 1))) + 0.1, txt);
    end
    plot(real(modulated_symbols), imag(modulated_symbols), '.', 'MarkerSize', 50, 'Color', color);
    hold off;
    ylim([-axlim, axlim]); xlim([-axlim, axlim]);
    set(gca, 'XAxisLocation', 'origin'); set(gca, 'YAxisLocation', 'origin');
    ax = gca; ax.XAxis.LineWidth = 2; ax.YAxis.LineWidth = 2;
    yticks([]); xticks([]); axis square;
end

%% Additive White Gaussian Noise
if ask_psk_or_qam
    noise = (randn(1, n_symbols) + 1i * randn(1, n_symbols)) * noise_level;
    tx_symbols = modulated_symbols;
    modulated_symbols = modulated_symbols + noise;
    
    if mod_type == "ASK"
        demodulated_symbols = round(modulated_symbols * order - 1);
    elseif mod_type == "PSK"
        demodulated_symbols = pskdemod(modulated_symbols, order);
    elseif mod_type == "QAM"
        demodulated_symbols = qamdemod(modulated_symbols, order, 'UnitAveragePower', true);
    end
    
    errors = sum(demodulated_symbols ~= symbols);
    SER = errors / length(symbols);
    disp("Number of errors: " + errors);
    disp("Symbol Error Rate (SER): " + SER);
end

%% modulated signal
time = (0 : n_symbols * sampling_frequency - 1) / sampling_frequency;

carrier_I = cos(2 * pi * time);
carrier_Q = sin(2 * pi * time);

if ask_psk_or_qam
    upsampled_symbols = repelem(modulated_symbols, sampling_frequency);
    modulated_signal = real(upsampled_symbols) .* carrier_I + ...
        imag(upsampled_symbols) .* carrier_Q;
else
    modulated_signal = real(modulated_signal) .* carrier_I + ...
        imag(modulated_signal) .* carrier_Q;
end

%% signal plot
color = "#233ce6";
max_ticks = 16; step = n_symbols / max_ticks;
if step < 1
    ticks = 0 : n_symbols;
else
    ticks = 0 : step : n_symbols;
end

figure;
plot(time, modulated_signal, 'Color', color, 'LineWidth', 1.5);
xticks(ticks); xlim([0, n_symbols]); xlabel('symbols');

%% constellation diagram (RX)
if ask_psk_or_qam
    colors = parula(order); colors = colors(randperm(order), :);
    figure;
    hold on;
    for i = 1 : length(modulated_symbols)
        plot(real(modulated_symbols(i)), imag(modulated_symbols(i)), '.', ...
            'Color', colors(symbols(i) + 1, :), 'MarkerSize', 20);
    end
    hold off;
    ylim([-axlim, axlim]); xlim([-axlim, axlim]);
    set(gca, 'XAxisLocation', 'origin'); set(gca, 'YAxisLocation', 'origin');
    ax = gca; ax.XAxis.LineWidth = 2; ax.YAxis.LineWidth = 2;
    yticks([]); xticks([]); axis square;
end
