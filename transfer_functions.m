% transfer_functions (S-shaped and V-shaped)
function p = transfer_functions(X, type)
    if isnumeric(type)
        switch type
            case 1, code = 'S1';
            case 2, code = 'S2';
            case 3, code = 'S3';
            case 4, code = 'S4';
            case 5, code = 'V1';
            case 6, code = 'V2';
            case 7, code = 'V3';
            case 8, code = 'V4';
            otherwise
                error('Unknown transfer function id: %d', type);
        end
    else
        code = char(upper(string(type)));
    end 

    switch code
        case 'S1'
            % S1: 1 / (1 + exp(-2x))
            p = 1 ./ (1 + exp(-2 .* X));
        case 'S2'
            p = 1 ./ (1 + exp(-1 .* X));
        case 'S3'
            p = 1 ./ (1 + exp(-X ./ 2));
        case 'S4'
            p = 1 ./ (1 + exp(-X ./ 3));

        case 'V1'
            p = abs(tanh(X));
        case 'V2'
            p = abs((2/pi) .* atan((pi/2) .* X));
        case 'V3'
            p = abs(X ./ sqrt(1 + X.^2));
        case 'V4'
            p = abs((1 - exp(-abs(X))) ./ (1 + exp(-abs(X))));

        otherwise
            error('Unknown transfer function type: %s', type);
    end
end
