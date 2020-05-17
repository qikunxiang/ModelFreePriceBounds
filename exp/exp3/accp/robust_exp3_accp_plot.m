% Script to plot the result of Experiment 3 with the ACCP algorithm

load('exp/exp3/exp3.mat');
load('exp/exp3/rst/accp.mat');

xx = 0:0.1:1;

figure('Position', [100,100,500,250]);
[ha, pos] = tight_subplot(1, 1, [0.15, 0.15], [0.13, 0.07], [0.08, 0.02]);
hold on;
sl = plot(xx, price_bounds(402:412, 2), ...
    'LineStyle', ':', 'Color', 'k', 'LineWidth', 1);
su = plot(xx, price_bounds(402:412, 1), ...
    'LineStyle', '-', 'Color', 'k', 'LineWidth', 1);
rl1 = plot(xx, out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'r', 'LineWidth', 1);
ru1 = plot(xx, out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'r', 'LineWidth', 1);
legend([sl, su, rl1, ru1], ...
    'simulated bid price', 'simulated ask price', ...
    'robust LB', 'robust UB', ...
    'Location', 'northeast');
legend boxoff
xlabel('strike');
ylabel('price');
title('ACCP');