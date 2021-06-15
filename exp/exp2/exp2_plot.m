load('exp/exp2/exp2.mat');
ecp_dat1 = load('exp/exp2/rst/accp_set1.mat');
ecp_dat2 = load('exp/exp2/rst/accp_set2.mat');
accp_dat1 = load('exp/exp2/rst/accp_set1.mat');
accp_dat2 = load('exp/exp2/rst/accp_set2.mat');

xx = 0:0.1:1;

figure('Position', [100,100,500,250]);
tight_subplot(1, 1, [0.15, 0.15], [0.13, 0.07], [0.08, 0.02]);
hold on;
sl = plot(xx, price_bounds(402:412, 2), ...
    'LineStyle', ':', 'Color', 'k', 'LineWidth', 1);
su = plot(xx, price_bounds(402:412, 1), ...
    'LineStyle', '-', 'Color', 'k', 'LineWidth', 1);
rl1 = plot(xx, ecp_dat1.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'b', 'LineWidth', 1);
ru1 = plot(xx, ecp_dat1.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'b', 'LineWidth', 1);
rl2 = plot(xx, ecp_dat2.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'r', 'LineWidth', 1);
ru2 = plot(xx, ecp_dat2.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'r', 'LineWidth', 1);
legend([sl, su, rl1, ru1, rl2, ru2], ...
    'reference bid price', 'reference ask price', ...
    'LB (V+B+S)', 'UB (V+B+S)', ...
    'LB (V+B+S+R)', 'UB (V+B+S+R)', ...
    'Location', 'northeast');
legend boxoff
xlabel('strike');
ylabel('price');
title('ECP');


figure('Position', [100,100,500,250]);
tight_subplot(1, 1, [0.15, 0.15], [0.13, 0.07], [0.08, 0.02]);
hold on;
sl = plot(xx, price_bounds(402:412, 2), ...
    'LineStyle', ':', 'Color', 'k', 'LineWidth', 1);
su = plot(xx, price_bounds(402:412, 1), ...
    'LineStyle', '-', 'Color', 'k', 'LineWidth', 1);
rl1 = plot(xx, accp_dat1.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'b', 'LineWidth', 1);
ru1 = plot(xx, accp_dat1.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'b', 'LineWidth', 1);
rl2 = plot(xx, accp_dat2.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'r', 'LineWidth', 1);
ru2 = plot(xx, accp_dat2.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'r', 'LineWidth', 1);
legend([sl, su, rl1, ru1, rl2, ru2], ...
    'reference bid price', 'reference ask price', ...
    'LB (V+B+S)', 'UB (V+B+S)', ...
    'LB (V+B+S+R)', 'UB (V+B+S+R)', ...
    'Location', 'northeast');
legend boxoff
xlabel('strike');
ylabel('price');
title('ACCP');

