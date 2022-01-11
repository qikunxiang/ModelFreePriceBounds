if ~exist('DIA', 'var')
    DIA1 = load('exp/exp4/exp_DIA1.mat');
end

if ~exist('data1_V25', 'var')
    data1_V25 = load('exp/exp4/rst/DIA1_ecp_V(25).mat', 'out_bounds');
end

if ~exist('data1_V50', 'var')
    data1_V50 = load('exp/exp4/rst/DIA1_ecp_V(50).mat', 'out_bounds');
end

if ~exist('data1_V100', 'var')
    data1_V100 = load('exp/exp4/rst/DIA1_ecp_V(100).mat', 'out_bounds');
end

if ~exist('data1_V100B', 'var')
    data1_V100B = load('exp/exp4/rst/DIA1_ecp_V(100)+B.mat', 'out_bounds');
end

if ~exist('DIA2', 'var')
    DIA2 = load('exp/exp4/exp_DIA2.mat');
end

if ~exist('data2_V25', 'var')
    data2_V25 = load('exp/exp4/rst/DIA2_ecp_V(25).mat', 'out_bounds');
end

if ~exist('data2_V50', 'var')
    data2_V50 = load('exp/exp4/rst/DIA2_ecp_V(50).mat', 'out_bounds');
end

if ~exist('data2_V100', 'var')
    data2_V100 = load('exp/exp4/rst/DIA2_ecp_V(100).mat', 'out_bounds');
end

if ~exist('data2_V100B', 'var')
    data2_V100B = load('exp/exp4/rst/DIA2_ecp_V(100)+B.mat', 'out_bounds');
end

figure('Position', [100,100,400,300]);
[ha, pos] = tight_subplot(1, 1, [0, 0], [0.105, 0.055], [0.08, 0.02]);
hold on;

V25UB = plot(DIA1.DIA_subset_strikes, data1_V25.out_bounds(:, 1), ...
    'LineStyle', '-', 'Color', 'blue');
V25LB = plot(DIA1.DIA_subset_strikes, data1_V25.out_bounds(:, 2), ...
    'LineStyle', ':', 'Color', 'blue');
% 
V50UB = plot(DIA1.DIA_subset_strikes, data1_V50.out_bounds(:, 1), ...
    'LineStyle', '-', 'Color', 'green');
V50LB = plot(DIA1.DIA_subset_strikes, data1_V50.out_bounds(:, 2), ...
    'LineStyle', ':', 'Color', 'green');

V100UB = plot(DIA1.DIA_subset_strikes, data1_V100.out_bounds(:, 1), ...
    'LineStyle', '-', 'Color', 'magenta');
V100LB = plot(DIA1.DIA_subset_strikes, data1_V100.out_bounds(:, 2), ...
    'LineStyle', ':', 'Color', 'magenta');

V100BUB = plot(DIA1.DIA_subset_strikes, data1_V100B.out_bounds(:, 1), ...
    'LineStyle', '-', 'Color', 'red');
V100BLB = plot(DIA1.DIA_subset_strikes, data1_V100B.out_bounds(:, 2), ...
    'LineStyle', ':', 'Color', 'red');

set(gca, 'XLim', [min(DIA1.DIA_subset_strikes), ...
    max(DIA1.DIA_subset_strikes)]);

legend([V25LB, V25UB, V50LB, V50UB, V100LB, V100UB, V100BLB, V100BUB], ...
    'LB V(25%)', 'UB V(25%)', 'LB V(50%)', 'UB V(50%)', ...
    'LB V(100%)', 'UB V(100%)', 'LB V(100%)+B', 'UB V(100%)+B');
legend boxoff;

xlabel('strike');
ylabel('price');
title('Basket call option $f_1$', 'Interpreter', 'latex');

figure('Position', [100,100,400,300]);
[ha, pos] = tight_subplot(1, 1, [0, 0], [0.105, 0.055], [0.08, 0.02]);
hold on;

V25UB = plot(DIA2.DIA_subset_strikes, data2_V25.out_bounds(:, 1), ...
    'LineStyle', '-', 'Color', 'blue');
V25LB = plot(DIA2.DIA_subset_strikes, data2_V25.out_bounds(:, 2), ...
    'LineStyle', ':', 'Color', 'blue');

V50UB = plot(DIA2.DIA_subset_strikes, data2_V50.out_bounds(:, 1), ...
    'LineStyle', '-', 'Color', 'green');
V50LB = plot(DIA2.DIA_subset_strikes, data2_V50.out_bounds(:, 2), ...
    'LineStyle', ':', 'Color', 'green');

V100UB = plot(DIA2.DIA_subset_strikes, data2_V100.out_bounds(:, 1), ...
    'LineStyle', '-', 'Color', 'magenta');
V100LB = plot(DIA2.DIA_subset_strikes, data2_V100.out_bounds(:, 2), ...
    'LineStyle', ':', 'Color', 'magenta');

V100BUB = plot(DIA2.DIA_subset_strikes, data2_V100B.out_bounds(:, 1), ...
    'LineStyle', '-', 'Color', 'red');
V100BLB = plot(DIA2.DIA_subset_strikes, data2_V100B.out_bounds(:, 2), ...
    'LineStyle', ':', 'Color', 'red');

set(gca, 'XLim', [min(DIA2.DIA_subset_strikes), ...
    max(DIA2.DIA_subset_strikes)]);

legend([V25LB, V25UB, V50LB, V50UB, V100LB, V100UB, V100BLB, V100BUB], ...
    'LB V(25%)', 'UB V(25%)', 'LB V(50%)', 'UB V(50%)', ...
    'LB V(100%)', 'UB V(100%)', 'LB V(100%)+B', 'UB V(100%)+B');
legend boxoff;

xlabel('strike');
ylabel('price');
title('Basket call option $f_2$', 'Interpreter', 'latex');

gap1_V100 = data1_V100.out_bounds(:, 1) - data1_V100.out_bounds(:, 2);
gap1_V100B = data1_V100B.out_bounds(:, 1) - data1_V100B.out_bounds(:, 2);
gap2_V100 = data2_V100.out_bounds(:, 1) - data2_V100.out_bounds(:, 2);
gap2_V100B = data2_V100B.out_bounds(:, 1) - data2_V100B.out_bounds(:, 2);

gap1_reduction_abs = gap1_V100 - gap1_V100B;
gap1_reduction_rel = gap1_reduction_abs ./ gap1_V100;
gap2_reduction_abs = gap2_V100 - gap2_V100B;
gap2_reduction_rel = gap2_reduction_abs ./ gap2_V100;

[gap1_reduction_abs_max, ind1] = max(gap1_reduction_abs);
gap1_reduction_abs_max_rel = gap1_reduction_rel(ind1);
[gap2_reduction_abs_max, ind2] = max(gap2_reduction_abs);
gap2_reduction_abs_max_rel = gap2_reduction_rel(ind2);

fprintf(['payoff f1: max abs reduction = %.2f, strike = %.2f, ' ...
    'reltive reduction = %.1f%%\n'], ...
    gap1_reduction_abs_max, DIA1.DIA_subset_strikes(ind1), ...
    gap1_reduction_abs_max_rel * 100);
fprintf(['payoff f2: max abs reduction = %.2f, strike = %.2f, ' ...
    'reltive reduction = %.1f%%\n'], ...
    gap2_reduction_abs_max, DIA2.DIA_subset_strikes(ind2), ...
    gap2_reduction_abs_max_rel * 100);