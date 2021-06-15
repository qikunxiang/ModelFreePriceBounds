% Step 2: detect arbitrage when one of the call-on-min/put-on-min options
% is present and when both are present

load('exp/exp3/exp3.mat');

price_bounds(57:58, :) = [0.85, 0.83; 3.20, 3.18];

[port, portlim] = portcreate(conf);

out_bounds = zeros(3, 1);
out_bounds_o = zeros(3, 1);
weights = cell(3, 1);
x_cell = cell(3, 1);
iterations = zeros(3, 1);
lp_counts = zeros(3, 1);
milp_counts = zeros(3, 1);
outputs = cell(3, 1);

for id = 1:3
    
    % when id == 1: only the call-on-min option is included as tradable, no
    % arbitrage opportunity is detected
    % when id == 2: only the put-on-min option is included as tradable, no
    % arbitrage opportunity is detected
    % when id == 3: both the call-on-min option and the put-on-min option
    % are included as tradable, an arbitrage opportunity is detected
    
    % the list of relevant instruments
    subset_list = true(port.m, 1);
    
    if id == 1
        subset_list(58) = false;
    elseif id == 2
        subset_list(57) = false;
    end
    
    repl = false(sum(subset_list), 1);
    subport = portsubset(port, subset_list);
    repl_size = sum(repl);
    price_bounds_subset = price_bounds(subset_list, :);
    price_traded = nonreplprice(price_bounds_subset, repl);
    weight_fixed = 0;
    
    init_lb = -1;
    init_ub = 0;
    
    options = struct('tol', 1e-3, 'init_rprice_lb', init_lb, ...
        'init_rprice_ub', init_ub, 'milp_gap', 0.01, ...
        'display', false);
    
    [rprice_ub, rprice_lb, weight_final, output] ...
        = lsipaccpalgo_gurobi( ...
        subport, price_traded, repl, weight_fixed, options);
    out_bounds(id) = rprice_ub;
    out_bounds_o(id) = rprice_lb;
    weights{id} = weight_final;
    x_cell{id} = output.x;
    iterations(id) = output.iter;
    lp_counts(id) = output.lp_count;
    milp_counts(id) = output.milp_count;
    outputs{id} = output;
    
    fprintf('option %d, upper bound = %.3f, iter = %d\n', id, ...
        out_bounds(id), output.iter);
end

save('exp/exp3/rst/accp_step2.mat');
