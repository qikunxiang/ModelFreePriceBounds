load('exp/exp4/exp_DIA_V(25).mat');

[port, portlim] = portcreate(conf);

boc_num = 1;
out_bounds = zeros(boc_num, 2);
out_bounds_o = zeros(boc_num, 2);
weights = cell(boc_num, 2);
x_cell = cell(boc_num, 2);
iterations = zeros(boc_num, 2);
outputs = cell(boc_num, 2);

tic;
for lu = 1:2
    % the list of relevant instruments
    repl = [false(port.m - 1, 1); true];
    repl_size = sum(repl);
    price_traded = nonreplprice(price_bounds, repl);
    weight_fixed = 3 - 2 * lu;
    
    if lu == 1
        init_lb = -1;
    else
        init_lb = -sum(price_bounds(index_range.call(:, 1), 1)) - 1;
    end
    
    
    options = struct('tol', 1e-3, 'drop_thres', 1, 'drop_iter', inf, ...
        'init_rprice_lb', init_lb, 'x_ub', 7000 * ones(conf.n, 1), ...
        'switch_to_simplex', true, 'display', true);
    
    if lu == 2
        options.init_x = x_cell{1, 1};
    end
    
    [rprice, rprice_lb, weight_final, output] = lsipecpalgo_gurobi( ...
        port, portlim, price_traded, repl, weight_fixed, ...
        options);
    out_bounds(1, lu) = rprice * (3 - 2 * lu);
    out_bounds_o(1, lu) = rprice_lb * (3 - 2 * lu);
    weights{1, lu} = weight_final;
    x_cell{1, lu} = output.x;
    iterations(1, lu) = output.iter;
    outputs{1, lu} = output;
    
    if lu == 1
        fprintf('upper bound = %.3f, iter = %d\n', ...
            out_bounds(1, lu), output.iter);
    else
        fprintf('lower bound = %.3f, iter = %d\n', ...
            out_bounds(1, lu), output.iter);
    end
end

compute_time = toc;

save('exp/exp4/rst/ecp_V(25).mat');