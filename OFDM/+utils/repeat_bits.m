function [bits] = repeat_bits(bitstream, order, n_symbols)
    bits_per_symbol = log2(order);
    n_bits = bits_per_symbol * n_symbols;
    factor = ceil(n_bits / length(bitstream));

    bits = repmat(bitstream, 1, factor);
    bits = bits(1 : n_bits);
    bits = reshape(bits, bits_per_symbol, []);
end

