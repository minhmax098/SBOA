% run SBOA S1 using cap71
clc; clear; close all;

% Parameters
pop_size   = 40;
iter_max   = 2000;
lb         = 0;
ub         = 1;
num_runs   = 20;
tf_type    = 1;   % S1

% list file & dimension
dosya_f = {'cap71_fi.xlsx'};
dosya_c = {'cap71_c.xlsx'};
dimension_d = [16];      % Cap71: 16 facility
nInst = numel(dosya_f);

Best    = zeros(nInst,1);
Worst   = zeros(nInst,1);
MeanVal = zeros(nInst,1);
StdVal  = zeros(nInst,1);
Gap     = zeros(nInst,1);
MeanCPU = zeros(nInst,1);

for inst = 1:nInst

    ff  = dosya_f{inst};
    cc  = dosya_c{inst};
    dim = dimension_d(inst);   % 16

    % Read data uflp
    f = xlsread(ff);   % 16x1 or 1x16
    f = f(:)';         % pressed into 1x16

    c = xlsread(cc);   % cost matrix
    % check dimension, if row ≠ dim then transpose
    if size(c,1) ~= dim && size(c,2) == dim
        c = c.';       % 16 x demands
    end

    fprintf('Running Binary SBOA S1 on %s / %s (facilities = %d)\n', ...
             ff, cc, dim);

    bestRuns = zeros(num_runs,1);
    cpuRuns  = zeros(num_runs,1);

    for r = 1:num_runs
        tic;
        [best_score, best_pos, curve] = SBOA_UFLP( ...
             pop_size, iter_max, lb, ub, dim, f, c, tf_type);
        bestRuns(r) = best_score;
        cpuRuns(r)  = toc;
    end

    Best(inst)    = min(bestRuns);
    Worst(inst)   = max(bestRuns);
    MeanVal(inst) = mean(bestRuns);
    StdVal(inst)  = std(bestRuns);
    Gap(inst)     = (MeanVal(inst) - Best(inst)) / Best(inst) * 100;
    MeanCPU(inst) = mean(cpuRuns);

    % Draw the convergence
    figure;
    plot(curve,'-b','LineWidth',2);
    xlabel('Iteration #');
    ylabel('Best UFLP cost');
    title(sprintf('Binary SBOA S1 on %s', ff));
    grid on;
end

DatasetId = (1:nInst)';
T = table(DatasetId, Best, Worst, MeanVal, StdVal, Gap, MeanCPU, ...
    'VariableNames', {'DatasetId','Best','Worst','Mean','Standard','Gap','MeanCPU'});
format bank
disp(T);
