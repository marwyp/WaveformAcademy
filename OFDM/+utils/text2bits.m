function [bits] = text2bits(text)
    ascii_values = double(text);
    binary_str = dec2bin(ascii_values, 8);
    bits = reshape(binary_str', 1, []);
    bits = bits - '0';
end

