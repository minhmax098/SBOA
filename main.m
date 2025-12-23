% Secretary Bird Optimization Algorithm(SBOA) for UFLP (cap71)
clc; clear; close all;

lb = 0;
ub = 1;

func = @uflp_func;         % fitness function (UFLP)
tf   = @transfer_functions;% transfer functions (S/V-shaped)

transfer_func = 'S2';

% UFLP datasets
dosya_f = {'cap71_fi.xlsx','cap72_fi.xlsx','cap73_fi.xlsx','cap74_fi.xlsx', ...
           'cap101_fi.xlsx','cap102_fi.xlsx','cap103_fi.xlsx','cap104_fi.xlsx', ...
           'cap131_fi.xlsx','cap132_fi.xlsx','cap133_fi.xlsx','cap134_fi.xlsx'};

dosya_c = {'cap71_c.xlsx','cap72_c.xlsx','cap73_c.xlsx','cap74_c.xlsx', ...
           'cap101_c.xlsx','cap102_c.xlsx','cap103_c.xlsx','cap104_c.xlsx', ...
           'cap131_c.xlsx','cap132_c.xlsx','cap133_c.xlsx','cap134_c.xlsx'};

% number of facilities for each instance
dimension_d = [16,16,16,16,25,25,25,25,50,50,50,50];

% (Optional) Optimum costs from the reference table (for Gap%)
Optimum = [932615.75, 977799.40, 1010641.45, 1034976.98, ...
           796648.44, 854704.20, 893782.11, 928941.75, ...
           793439.56, 851495.33, 893076.71, 928941.75]';

% SBOA parameters
pop_size = 40;
iter_max = 2000;
num_runs = 20; 

nInst = numel(dosya_f);
DatasetId = strcat("Id", string((1:nInst)'));

% result arrays
Best    = zeros(nInst,1);
Worst   = zeros(nInst,1);
MeanVal = zeros(nInst,1);
StdVal  = zeros(nInst,1);
Gap     = zeros(nInst,1);
MeanCPU = zeros(nInst,1);

fprintf('\n  Running TF = %s \n', string(transfer_func));

for inst = 1:nInst

    ff  = dosya_f{inst};
    cc  = dosya_c{inst};
    dim = dimension_d(inst);

    % Read UFLP data
    f = xlsread(ff);   % opening costs
    f = f(:)';         % force row vector 1 x dim

    c_raw = xlsread(cc);

    % Quy tắc: nếu số cột = dim => c_raw đang là demands x facilities => transpose
    if size(c_raw,2) == dim
        c = c_raw.';              % -> facilities x demands
    elseif size(c_raw,1) == dim
        c = c_raw;                % đã là facilities x demands
    else
        error('Dataset %s: cannot match dim=%d. size(c)=%dx%d', ...
              cc, dim, size(c_raw,1), size(c_raw,2));
    end
    
    % Check chắc chắn
    if size(c,1) ~= dim
        error('After orientation, c rows must be dim. Got %d vs dim=%d', size(c,1), dim);
    end

    y_all = ones(1, dim);
    cost_all_open = uflp_func(y_all, f, c);

    fprintf('Inst=%d | dim=%d | Optimum=%.3f | All-open cost=%.3f\n', ...
        inst, dim, Optimum(inst), cost_all_open);

    fprintf('f min/max = %.3f / %.3f\n', min(f), max(f));
    fprintf('c min/max = %.3f / %.3f\n', min(c(:)), max(c(:)));

    fprintf('TF=%s | %s / %s | facilities=%d | demands=%d\n', ...
        string(transfer_func), ff, cc, dim, size(c,2));

    bestRuns = zeros(num_runs,1);
    cpuRuns  = zeros(num_runs,1);

    for r = 1:num_runs
        tic;
        
        [best_score, ~, ~] = SBOA_UFLP( ...
            pop_size, iter_max, lb, ub, dim, f, c, transfer_func, func, tf);
        cpuRuns(r)  = toc;
        bestRuns(r) = best_score;
    end

    Best(inst)    = min(bestRuns);

    Worst(inst)   = max(bestRuns);
    MeanVal(inst) = mean(bestRuns);
    StdVal(inst)  = std(bestRuns);
    MeanCPU(inst) = mean(cpuRuns);

    % Gap % using Optimum
    Gap(inst) = (MeanVal(inst) - Optimum(inst)) / Optimum(inst) * 100;
end

T = table(DatasetId, Best, Worst, MeanVal, StdVal, Gap, MeanCPU, ...
    'VariableNames', {'DatasetId','Best','Worst','Mean','Standard','Gap','MeanCPUTime'});

% Display 3 decimals
T_word = T;
T_word.Best     = compose('%.3f', T.Best);
T_word.Worst    = compose('%.3f', T.Worst);
T_word.Mean     = compose('%.3f', T.Mean);
T_word.Standard = compose('%.3f', T.Standard);
T_word.Gap      = compose('%.3f', T.Gap);
T_word.MeanCPUTime = compose('%.3f', T.MeanCPUTime);

disp(' ');
disp("Table for TF = " + string(transfer_func) + " ");
disp(T_word);

