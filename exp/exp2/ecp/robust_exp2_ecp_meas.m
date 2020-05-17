% Script to plot the two-dimensional projections of the optimal measure in
% Experiment 2 with the ACCP algorithm

load('exp/exp2/rst/ecp_set1.mat');

id = 36;


for lu = 1:2

x_opt = outputs{id, lu}.x;
measure_opt = max(outputs{id, lu}.measure, 0);

% thres = 2e-4;
% list = measure_opt >= thres;
% bin_max = ceil(max(max(x_opt(:, list))));
bin_max = 20;

d = 5;

D = repmat((1:d - 1)', 1, d - 1);
D2 = D';
dd1 = D2(:);
dd2 = D(:);

figure('Position', [100, 100, 500, 400]);
[ha, pos] = tight_subplot(d - 1, d - 1, [0.03, 0.025], ...
    [0.10, 0.08], [0.10, 0.14], dd1 >= dd2);
ex = 0.4;

ii = 0;
for d1 = 2:d
    for d2 = 1:d1 - 1
        ii = ii + 1;
        axes(ha(ii));
        box on;
        x_sel = x_opt([d1, d2], :);
        sel_list = max(x_sel, [], 1) <= bin_max;
        x_sel = x_sel(:, sel_list);
        x_sel = ceil(x_sel);
        x_sel(x_sel == 0) = 1;
        
        P = full(sparse(x_sel(1, :), x_sel(2, :), ...
            measure_opt(sel_list), bin_max, bin_max));
        image([0, bin_max], [0, bin_max], P .^ ex, ...
            'CDataMapping', 'scaled');
        caxis([0, 0.2 ^ ex]);
        set(ha(ii), 'YDir', 'normal');
        view(2)
        colormap(flipud(hot))
        if d1 == 5
            xlabel(sprintf('x_%d', d2), 'Interpreter', 'tex');
        else
            set(ha(ii), 'XTick', []);
        end
        
        if d2 == 1
            ylabel(sprintf('x_%d', d1), 'Interpreter', 'tex');
        else
            set(ha(ii), 'YTick', []);
        end
    end
end

if lu == 1
    sgtitle('ECP - Upper Bound', 'FontWeight', 'bold', 'FontSize', 12);
else
    sgtitle('ECP - Lower Bound', 'FontWeight', 'bold', 'FontSize', 12);
end
color_ticks = (0:10) / 10 * 0.2 ^ ex;
color_labels = cell(length(color_ticks), 1);
for j = 1:length(color_ticks)
    color_labels{j} = sprintf('%.3f', color_ticks(j) .^ (1 / ex));
end
colorbar('Position', [0.9, 0.10, 0.04, 0.82], ...
    'Ticks', color_ticks, 'TickLabels', color_labels);

end