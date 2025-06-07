clearvars; close all;
color{1} = '#233ce6';
color{2} = '#ff5757';

%% Parameters
n_subcarriers = 128;
n_symbols = 20;
scs = 15e3;
data_order = 16;
pilot_order = 4;
cp_length = 20;
pilot_sc_loc = 4;
pilot_sym_loc = 4;
data{1} = 'Waveform Academy ';
data{2} = 'abcdefghijklmnopqrstuvwxyz ';

%% Data & Pilot Locations
pilot_locations{1} = false(n_subcarriers, n_symbols);
pilot_locations{1}(1 : pilot_sym_loc : end, 1 : pilot_sc_loc : end) = true;

pilot_locations{2} = false(n_subcarriers, n_symbols);
pilot_locations{2}(pilot_sc_loc / 2 + 1 : pilot_sc_loc : end, ...
    1 : pilot_sym_loc : end) = true;

data_locations = true(n_subcarriers, n_symbols);
data_locations(pilot_locations{1} | pilot_locations{2}) = false;

figure;
img = zeros(n_subcarriers, n_symbols);
img(data_locations) = 0;
img(pilot_locations{1}) = 1;
img(pilot_locations{2}) = 2;
cmap = uint8([
    255 255 255
    35  60  230
    255 87  87
]);

imagesc(img);
colormap(cmap);

%% Create QAM Symbols
n_ports = 2;
data_bits = cell(1, n_ports);
data_states = cell(1, n_ports);
pilot_states = cell(1, n_ports);

for p = 1 : n_ports
    bitstream = utils.text2bits(data{p});
    data_bits{p} = utils.repeat_bits(bitstream, data_order, ...
        sum(sum(data_locations)));
    data_states{p} = qammod(data_bits{p}, data_order, 'gray', ...
        'InputType', 'bit', 'UnitAveragePower', true);

    pilot_symbols = randi(pilot_order, n_subcarriers / pilot_sc_loc, ...
        n_symbols / pilot_sym_loc) - 1;
    pilot_states{p} = qammod(pilot_symbols, pilot_order, 'gray', ...
        'UnitAveragePower', true);
end

%% OFDM Modulation
tx_grid = cell(1, n_ports);
tx_signal = cell(1, n_ports);
for p = 1 : n_ports
    tx_grid{p} = zeros(n_subcarriers, n_symbols);
    tx_grid{p}(data_locations) = data_states{p};
    tx_grid{p}(pilot_locations{p}) = pilot_states{p};
    tx_signal{p} = ofdmmod(tx_grid{p}, n_subcarriers, cp_length);

    figure;
    plot(real(tx_grid{p}(data_locations)), ...
        imag(tx_grid{p}(data_locations)), 'o', 'Color', color{p});
    axlim = max(max(abs(tx_grid{p}))) + 0.05;
    ylim([-axlim, axlim]); xlim([-axlim, axlim]); axis square;
    xlabel("In-phase"); ylabel("Quadrature");
end

%% Channel
fs = n_subcarriers * scs;
mimoChan = comm.MIMOChannel('SampleRate', fs, ...
    'PathDelays', [0 1.5e-6], ...
    'AveragePathGains', [0 -5], ...
    'MaximumDopplerShift', 5, ...
    'SpatialCorrelationSpecification', 'None', ...
    'NumTransmitAntennas', 2, ...
    'NumReceiveAntennas', 2, ...
    'RandomStream', 'mt19937ar with seed', ...
    'Seed', 12);
rx_signal = mimoChan([tx_signal{1}, tx_signal{2}]);

%% OFDM Demodulation
rx_grid = cell(1, n_ports);
for p = 1 : n_ports
    rx_grid{p} = ofdmdemod(rx_signal(:, p), n_subcarriers, cp_length);

    figure;
    plot(real(rx_grid{p}(data_locations)), ...
        imag(rx_grid{p}(data_locations)), 'o', 'Color', color{p});
    axlim = max(max(abs(rx_grid{p}))) + 0.05;
    ylim([-axlim, axlim]); xlim([-axlim, axlim]); axis square;
    xlabel("In-phase"); ylabel("Quadrature");
end

%% Channel Estimation
hest = cell(n_ports, n_ports);
[X{1}, Y{1}] = meshgrid(1 : pilot_sym_loc : n_symbols, ...
    1 : pilot_sc_loc : n_subcarriers);
[X{2}, Y{2}] = meshgrid(1 : pilot_sym_loc : n_symbols, ...
    1 + pilot_sc_loc / 2 : pilot_sc_loc : n_subcarriers);
[Xq, Yq] = meshgrid(1 : n_symbols, 1 : n_subcarriers);
for p_tx = 1 : n_ports
    for p_rx = 1 : n_ports
        hest_pilots = reshape(rx_grid{p_rx}(pilot_locations{p_tx}), ...
            n_subcarriers / pilot_sc_loc, n_symbols / pilot_sym_loc) ...
            ./ pilot_states{p_tx};
        hest{p_tx}{p_rx} = interp2(X{p_tx}, Y{p_tx}, hest_pilots, ...
            Xq, Yq, "spline");
    end
end

%% Equalize Data
est_grid = zeros(n_subcarriers, n_symbols, 2);
for k = 1 : n_subcarriers
    for t = 1 : n_symbols
        H = [
            hest{1}{1}(k, t), hest{2}{1}(k, t);
            hest{1}{2}(k, t), hest{2}{2}(k, t)
        ];
        y = [rx_grid{1}(k, t); rx_grid{2}(k, t)];
        est_grid(k, t, :) = pinv(H) * y;
    end
end

for p = 1 : n_ports 
    figure;
    plot(real(est_grid(:, :, p)), imag(est_grid(:, :, p)), ...
        'o', 'Color', color{p});
    axlim = max(max(abs(est_grid(:, :, p)))) + 0.05;
    ylim([-axlim, axlim]); xlim([-axlim axlim]); axis square;
    xlabel("In-phase"); ylabel("Quadrature");
end

%% QAM Demodulation
for p = 1 : n_ports
    data_states_rx = est_grid(:, :, p);
    data_states_rx = data_states_rx(data_locations);
    data_bits_rx = qamdemod(data_states_rx, data_order, "gray", ...
        "OutputType", "bit", "UnitAveragePower", true);
    data_rx = utils.bits2text(data_bits_rx);
    n_errors = sum(data_bits_rx ~= data_bits{p}(:));
    BER = n_errors / length(data_bits_rx);

    disp("Port " + p);
    disp(" BER: " + BER);
    disp(" Data: " + data_rx);
end