% Script to plot the result of Experiment 4

load('exp/exp4/rst/ecp.mat');

num = 10;
x = 1:num;
xtl = cell(num, 1);
for i = 1:num
    xtl{i} = sprintf('f_{%d}', i);
end

sim_prices = price_bounds(441:end, :);


figure('Position', [100, 100, 500, 300]);
[ha, pos] = tight_subplot(1, 1, [0.15, 0.15], [0.12, 0.02], [0.07, 0.01]);
hold on;

for i = 1:num
    ls = line(i + [-0.2; 0.2], repmat(sim_prices(i, 1), 2, 1), ...
        'color', 'blue', 'LineWidth', 1.2);
    line(i + [-0.2; 0.2], repmat(sim_prices(i, 2), 2, 1), ...
        'color', 'blue', 'LineWidth', 1.2);
    line([i; i], sim_prices(i, 1:2)', ...
        'color', 'blue', 'LineStyle', ':', 'LineWidth', 1);
    lc = line(i + [-0.4; 0.4], repmat(out_bounds(i, 1), 2, 1), ...
        'color', 'red', 'LineWidth', 1.5);
    line(i + [-0.4; 0.4], repmat(out_bounds(i, 2), 2, 1), ...
        'color', 'red', 'LineWidth', 1.5);
end
ylabel('price');
xlabel('payoff function');
set(gca, 'XTick', 1:10);
set(gca, 'XTickLabel', xtl);
set(gca, 'XLim', [0, 11]);
legend([ls, lc], 'simulated bid/ask prices', 'robust LB/UB', ...
    'Location', 'southwest');
legend boxoff
