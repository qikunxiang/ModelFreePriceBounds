load('exp/exp4/DIA.mat');
list = ['DIA'; tickers];

rst = zeros(length(list), 1);
weights = cell(length(list), 1);

for i = 1:length(list)

    load(['exp/exp4/sanitize/before_sanitize_', list{i}, '.mat']);

    [port, portlim] = portcreate(conf);

    repl = false(size(price_bounds, 1), 1);
    price_traded = nonreplprice(price_bounds, repl);
    weight_fixed = 0;

    init_lb = -1;


    options = struct('tol', 1e-3, 'drop_thres', 1, ...
        'init_rprice_lb', init_lb, 'x_ub', 7000 * ones(conf.n, 1), ...
        'display', false);

    [rprice, rprice_lb, weight_final, output] = lsipecpalgo_gurobi( ...
        port, portlim, price_traded, repl, weight_fixed, ...
        options);
    rst(i) = rprice;
    weights{i} = weight_final;

    fprintf('upper bound = %.3f\n', rprice);
end