% Binary Secretary Bird Optimization Algorithm for UFLP

function [Best_score, Best_pos, SBOA_curve] = SBOA_UFLP( ...
    pop_size, iter_max, lb, ub, dim, f, c, transfer_func, func, tf)

    % defaults if omitted
    if nargin < 9 || isempty(func)
        func = @uflp_func;
    end
    if nargin < 10 || isempty(tf)
        tf = @transfer_functions;
    end

    % bounds as row vectors
    lb = ones(1, dim) * lb;
    ub = ones(1, dim) * ub;

    % map transfer function selection to string code
    if isnumeric(transfer_func)
        switch transfer_func
            case 1, tfType = 'S1';
            case 2, tfType = 'S2';
            case 3, tfType = 'S3';
            case 4, tfType = 'S4';
            case 5, tfType = 'V1';
            case 6, tfType = 'V2';
            case 7, tfType = 'V3';
            case 8, tfType = 'V4';
            otherwise, tfType = 'S1';
        end
    else
        tfType = char(upper(string(transfer_func)));  % 'S1','V2',...
    end

    % Initialization
    X   = rand(pop_size, dim) .* (ub - lb) + lb;   % continuous positions
    Y   = zeros(pop_size, dim);                    % binary patterns
    fit = zeros(pop_size, 1);

    for i = 1:pop_size
        p  = tf(X(i, :), tfType);          % probability via transfer function
        yi = double(rand(1, dim) <= p);    % binarization
        if all(yi == 0)
            yi(randi(dim)) = 1;            % ensure at least 1 facility open
        end
        Y(i, :)   = yi;
        fit(i, 1) = func(yi, f, c);        % UFLP fitness
    end

    best_so_far = zeros(1, iter_max);

    % Main loop
    for t = 1:iter_max
        CF = (1 - t/iter_max)^(2 * t/iter_max);

        % current global best
        [fbest, idxBest] = min(fit);
        Bast_X = X(idxBest, :);
        Bast_Y = Y(idxBest, :);

        % Predation strategy
        for i = 1:pop_size
            if t < iter_max/3
                % Stage 1: search prey
                Xr1 = randi(pop_size);
                Xr2 = randi(pop_size);
                R1  = rand(1, dim);
                X1  = X(i, :) + (X(Xr1, :) - X(Xr2, :)) .* R1;

            elseif t < 2*iter_max/3
                % Stage 2: approaching prey
                RB = randn(1, dim);
                X1 = Bast_X + exp((t/iter_max)^4) .* (RB - 0.5) .* (Bast_X - X(i, :));

            else
                % Stage 3: attacking prey (Levy flight)
                RL = 0.5 * Levy(dim);
                X1 = Bast_X + CF .* X(i, :) .* RL;
            end

            % clamp to bounds
            X1 = max(X1, lb);
            X1 = min(X1, ub);

            % binarize & evaluate
            p1 = tf(X1, tfType);
            y1 = double(rand(1, dim) <= p1);
            if all(y1 == 0)
                y1(randi(dim)) = 1;
            end

            f_newP1 = func(y1, f, c);

            if f_newP1 <= fit(i)
                X(i, :)   = X1;
                Y(i, :)   = y1;
                fit(i, 1) = f_newP1;
            end
        end

        % Escape strategy
        r = rand;
        Xrandom = X(randperm(pop_size, 1), :);

        for i = 1:pop_size
            if r < 0.5
                % C1: hide using environment
                RB = rand(1, dim);
                X2 = Bast_X + (1 - t/iter_max)^2 .* (2*RB - 1) .* X(i, :);
            else
                % C2: fly or run away
                K  = round(1 + rand);
                R2 = rand(1, dim);
                X2 = X(i, :) + R2 .* (Xrandom - K .* X(i, :));
            end

            X2 = max(X2, lb);
            X2 = min(X2, ub);

            p2 = tf(X2, tfType);
            y2 = double(rand(1, dim) <= p2);
            if all(y2 == 0)
                y2(randi(dim)) = 1;
            end

            f_newP2 = func(y2, f, c);

            if f_newP2 <= fit(i)
                X(i, :)   = X2;
                Y(i, :)   = y2;
                fit(i, 1) = f_newP2;
            end
        end

        % update best after full update
        [fbest, idxBest] = min(fit);
        Bast_Y = Y(idxBest, :);

        best_so_far(t) = fbest;
    end

    Best_score = min(fit);
    Best_pos   = Bast_Y;        % best binary opening pattern
    SBOA_curve = best_so_far;
end

% Levy flight helper
function o = Levy(d)
    beta  = 1.5;
    sigma = (gamma(1+beta)*sin(pi*beta/2) / ...
            (gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
    u     = randn(1, d) * sigma;
    v     = randn(1, d);
    o     = u ./ abs(v).^(1/beta);
end
