function cfg = config(numSubframes, fc)
    cfg = nrDLCarrierConfig;

    % Basic Configuration
    cfg.NCellID = 101;
    cfg.FrequencyRange = 'FR1';
    cfg.NumSubframes = numSubframes;
    cfg.CarrierFrequency = fc;

    % PDSCH Configuration
    pdsch = nrWavegenPDSCHConfig;
    pdsch.Enable = false;
    cfg.PDSCH{1} = pdsch;
end

