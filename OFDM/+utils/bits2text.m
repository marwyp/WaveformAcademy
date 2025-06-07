function [text] = bits2text(bits)
    binary_vector = bits(:)';
    padLength = mod(-numel(binary_vector), 8);
    binary_vector = [binary_vector, zeros(1, padLength)];
    binary_matrix = reshape(binary_vector, 8, [])';
    decimals = bin2dec(char(binary_matrix + '0'));

    text = char(decimals)';
    text = strip(text, char(0));
end

