load('exp/exp1/exp1.mat');

xx = (0:50) / 5;

for fig_id = 1:4

if fig_id == 1
    % ECP algorithm
    dat_V = load('exp/exp1/rst/ecp_V.mat');
    dat_VB = load('exp/exp1/rst/ecp_V+B.mat');
    dat_VBS = load('exp/exp1/rst/ecp_V+B+S.mat');
    dat_VBSR = load('exp/exp1/rst/ecp_V+B+S+R.mat');
else
    % ACCP algorithm
    dat_V = load('exp/exp1/rst/accp_V.mat');
    dat_VB = load('exp/exp1/rst/accp_V+B.mat');
    dat_VBS = load('exp/exp1/rst/accp_V+B+S.mat');
    dat_VBSR = load('exp/exp1/rst/accp_V+B+S+R.mat');
    dat_VR = load('exp/exp1/rst/accp_V+R.mat');
end
    
figure('Position', [100,100,400,300]);
[ha, pos] = tight_subplot(1, 1, [0, 0], [0.105, 0.055], [0.08, 0.02]);
hold on;
sl = plot(xx, price_bounds(441:491, 2), ...
    'LineStyle', ':', 'Color', 'k', 'LineWidth', 1);
su = plot(xx, price_bounds(441:491, 1), ...
    'LineStyle', '-', 'Color', 'k', 'LineWidth', 1);
rl_V = plot(xx, dat_V.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'b', 'LineWidth', 1.5);
ru_V = plot(xx, dat_V.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'b', 'LineWidth', 1.5);
rl_VB = plot(xx, dat_VB.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'm', 'LineWidth', 1);
ru_VB = plot(xx, dat_VB.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'm', 'LineWidth', 1);
rl_VBS = plot(xx, dat_VBS.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'g', 'LineWidth', 1);
ru_VBS = plot(xx, dat_VBS.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'g', 'LineWidth', 1);
rl_VBSR = plot(xx, dat_VBSR.out_bounds(:, 2), 'LineStyle', ':', ...
    'Color', 'r', 'LineWidth', 1);
ru_VBSR = plot(xx, dat_VBSR.out_bounds(:, 1), 'LineStyle', '-', ...
    'Color', 'r', 'LineWidth', 1);

if fig_id == 4
    % with the additional Case V+R
    rl_VR = plot(xx, dat_VR.out_bounds(:, 2), 'LineStyle', ':', ...
        'Color', '#FFB319', 'LineWidth', 1);
    ru_VR = plot(xx, dat_VR.out_bounds(:, 1), 'LineStyle', '-', ...
        'Color', '#FFB319', 'LineWidth', 1);
    lgd = legend([sl, su, rl_V, ru_V, rl_VB, ru_VB, rl_VBS, ru_VBS, ...
        rl_VBSR, ru_VBSR, rl_VR, ru_VR], ...
        'reference bid price', 'reference ask price', ...
        'LB (V)', 'UB (V)', ...
        'LB (V+B)', 'UB (V+B)', ...
        'LB (V+B+S)', 'UB (V+B+S)', ...
        'LB (V+B+S+R)', 'UB (V+B+S+R)', ...
        'LB (V+R)', 'UB (V+R)', ...
        'Location', 'northeast');
    lgd.NumColumns = 2;
else
    legend([sl, su, rl_V, ru_V, rl_VB, ru_VB, rl_VBS, ru_VBS, ...
        rl_VBSR, ru_VBSR], ...
        'reference bid price', 'reference ask price', ...
        'LB (V)', 'UB (V)', ...
        'LB (V+B)', 'UB (V+B)', ...
        'LB (V+B+S)', 'UB (V+B+S)', ...
        'LB (V+B+S+R)', 'UB (V+B+S+R)', ...
        'Location', 'northeast');
end

legend boxoff

if fig_id == 1
    title('ECP');
elseif fig_id == 2
    title('ACCP');
elseif fig_id == 3
    title('Magnified');
    set(gca, 'XLim', [2.7, 4.3]);
    set(gca, 'YLim', [0.3, 2.2]);
else
    title('With Case V+R');
    set(gca, 'XLim', [1.3, 2.9]);
    set(gca, 'YLim', [0.9, 3.7]);
end

xlabel('strike');
ylabel('price');

end