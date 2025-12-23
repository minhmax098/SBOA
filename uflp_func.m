% UFLP function
% cost = sum_i f_i y_i + sum_j min_{i: y_i=1} c_ij

function cost = uflp_func(y, f, c)
% y : 1 x nFacilities, binary vector (1 = open, 0 = closed)
% f : 1 x nFacilities (or nFacilities x 1), opening costs
% c : nFacilities x nDemands, shipping/service costs

    % y ve f is the row vector
    y = y(:)';       % 1 x n
    f = f(:)';       % 1 x n

    [nFacilities, ~] = size(c);

    if length(y) ~= nFacilities
        error('Length of y (%d) does not match number of facilities in c (%d).', ...
               length(y), nFacilities);
    end

    % cost of opening a facility
    openingCost = sum(f .* y);   % ∑ f_i y_i

    % cost of customer service
    % if facility closed (y_i = 0) → assign huge costs to not be selected
    % M = 1e12;                     % penalty big
    M = max(c(:)) + max(f) + 1;
    costMat = c;                  % copy
    costMat(y == 0, :) = M;       % set huge cost for facility closing

    % For each customer j, take the minimum cost from the open facilities.
    minCostPerDemand = min(costMat, [], 1);  % 1 x nDemands
    serviceCost = sum(minCostPerDemand);          % ∑_j min_i c_ij

    % Total UFLP cost
    cost = openingCost + serviceCost;
end
