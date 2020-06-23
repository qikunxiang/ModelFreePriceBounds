load('exp/exp1/exp1.mat');
dat1 = load('exp/exp1/rst/accp_set1.mat');
dat2 = load('exp/exp1/rst/accp_set2.mat');
dat3 = load('exp/exp1/rst/accp_set3.mat');
dat4 = load('exp/exp1/rst/accp_set4.mat');

xx = (0:50) / 5;

for fig_id = 1:2
figure('Position', [100,100,500,400]);
[ha, pos] = tight_subplot(1, 1, [0.15, 0.15], [0.08, 0.04], [0.08, 0.02]);
hold on;
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
legend([su, rl4, ru4, rl3, ru3, rl2, ru2, rl1, ru1], ...
    'simulated price', ...
    'LB (V)', 'UB (V)', ...
    'LB (V+B)', 'UB (V+B)', ...
    'LB (V+B+S)', 'UB (V+B+S)', ...
    'LB (V+B+S+R)', 'UB (V+B+S+R)', ...
    'Location', 'northeast');
legend boxoff
xlabel('strike');
ylabel('price');

if fig_id == 1
    title('ACCP');
else
    title('Magnified');
    set(gca, 'XLim', [3, 4.5]);
    set(gca, 'YLim', [0.4, 1.8]);
end

end