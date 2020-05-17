% Script to plot the result of Experiment 2 with the ECP algorithm

load('exp/exp2/exp2.mat');
dat1 = load('exp/exp2/rst/ecp_set1.mat');
dat2 = load('exp/exp2/rst/ecp_set2.mat');
dat3 = load('exp/exp2/rst/ecp_set3.mat');
dat4 = load('exp/exp2/rst/ecp_set4.mat');

xx = (0:50) / 5;

figure('Position', [100,100,500,400]);
[ha, pos] = tight_subplot(1, 1, [0.15, 0.15], [0.08, 0.04], [0.08, 0.02]);
hold on;
sl = plot(xx, price_bounds(441:491, 2), ...
    'LineStyle', ':', 'Color', 'k', 'LineWidth', 1);
su = plot(xx, price_bounds(441:491, 1), ...
    'LineStyle', '-', 'Color', 'k', 'LineWidth', 1);
rl4 = plot(xx, dat4.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'b', 'LineWidth', 1);
ru4 = plot(xx, dat4.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'b', 'LineWidth', 1);
rl3 = plot(xx, dat3.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'm', 'LineWidth', 1);
ru3 = plot(xx, dat3.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'm', 'LineWidth', 1);
rl2 = plot(xx, dat2.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'g', 'LineWidth', 1);
ru2 = plot(xx, dat2.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'g', 'LineWidth', 1);
rl1 = plot(xx, dat1.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'r', 'LineWidth', 1);
ru1 = plot(xx, dat1.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'r', 'LineWidth', 1);
legend([sl, su, rl4, ru4, rl3, ru3, rl2, ru2, rl1, ru1], ...
    'simulated bid price', 'simulated ask price', ...
    'robust LB (V)', 'robust UB (V)', ...
    'robust LB (V+B)', 'robust UB (V+B)', ...
    'robust LB (V+B+S)', 'robust UB (V+B+S)', ...
    'robust LB (V+B+S+R)', 'robust UB (V+B+S+R)', ...
    'Location', 'northeast');
legend boxoff
xlabel('strike');
ylabel('price');
title('ECP');