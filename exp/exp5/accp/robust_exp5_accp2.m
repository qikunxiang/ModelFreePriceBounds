% Script to run the second part of Experiment 5

load('exp/exp5/exp5_2.mat');

[port, portlim] = portcreate(conf);


tic;
% the list of relevant instruments
subset_list = true(port.m, 1);

subset_list(441:491) = false;
subset_list(446) = true;
repl = [false(440, 1); false;];

subport = portsubset(port, subset_list);
repl_size = sum(repl);
price_bounds_subset = price_bounds(subset_list, :);
price_traded = nonreplprice(price_bounds_subset, repl);
weight_fixed = [];

init_lb = -1;
init_ub = sum(price_bounds(2:4, 1));

options = struct('tol', 1e-3, 'init_rprice_lb', init_lb, ...
    'init_rprice_ub', init_ub);

[rprice_ub, rprice_lb, weight_final, output] ...
    = lsipaccpalgo_gurobi( ...
    subport, price_traded, repl, weight_fixed, options);
out_bounds = rprice_ub;
out_bounds_o = rprice_lb;
weights = {weight_final};
x_cell = {output.x};
iterations = output.iter;
lp_counts = output.lp_count;
milp_counts = output.milp_count;

fprintf('upper bound = %.3f, iter = %d\n', ...
    out_bounds, output.iter);

compute_time = toc;

W = weights{1};
W(abs(W) < 0.01) = 0;
W = sparse(W);

save('exp/exp5/rst/accp_set2.mat');
