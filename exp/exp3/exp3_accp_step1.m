% Step 1: compute the price bounds on the call-on-min and put-on-min
% options

load('exp/exp3/exp3.mat');

[port, portlim] = portcreate(conf);

out_bounds = zeros(2, 2);
out_bounds_o = zeros(2, 2);
weights = cell(2, 2);
x_cell = cell(2, 2);
iterations = zeros(2, 2);
lp_counts = zeros(2, 2);
milp_counts = zeros(2, 2);
outputs = cell(2, 2);

for id = 1:2
    for lu = 1:2
        % the list of relevant instruments
        subset_list = true(port.m, 1);
        
        if id == 1
            subset_list(58) = false;
        else
            subset_list(57) = false;
        end
        
        repl = [false(56, 1); true];
        subport = portsubset(port, subset_list);
        repl_size = sum(repl);
        price_bounds_subset = price_bounds(subset_list, :);
        price_traded = nonreplprice(price_bounds_subset, repl);
        weight_fixed = 3 - 2 * lu;
        
        if id == 1
            if lu == 1
                init_lb = -1;
                init_ub = sum(price_bounds(2:6, 1));
            else
                init_lb = -sum(price_bounds(2:6, 1)) - 1;
                init_ub = 0;
            end
        else
            if lu == 1
                init_lb = -1;
                init_ub = 4;
            else
                init_lb = -5;
                init_ub = 0;
            end
        end
        
        options = struct('tol', 1e-3, 'init_rprice_lb', init_lb, ...
            'init_rprice_ub', init_ub, 'milp_gap', 0.01, ...
            'display', false);
        
        [rprice_ub, rprice_lb, weight_final, output] ...
            = lsipaccpalgo_gurobi( ...
            subport, price_traded, repl, weight_fixed, options);
        out_bounds(id, lu) = rprice_ub * (3 - 2 * lu);
        out_bounds_o(id, lu) = rprice_lb * (3 - 2 * lu);
        weights{id, lu} = weight_final;
        x_cell{id, lu} = output.x;
        iterations(id, lu) = output.iter;
        lp_counts(id, lu) = output.lp_count;
        milp_counts(id, lu) = output.milp_count;
        outputs{id, lu} = output;
        
        if lu == 1
            fprintf('option %d, upper bound = %.3f, iter = %d\n', id, ...
                out_bounds(id, lu), output.iter);
        else
            fprintf('option %d, lower bound = %.3f, iter = %d\n', id, ...
                out_bounds(id, lu), output.iter);
        end
    end
end

save('exp/exp3/rst/accp_step1.mat');
