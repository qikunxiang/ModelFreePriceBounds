% Script to run Experiment 4

load('exp/exp4/exp4.mat');

[port, portlim] = portcreate(conf);

boc_num = 10;
out_bounds = zeros(boc_num, 2);
out_bounds_o = zeros(boc_num, 2);
weights = cell(boc_num, 2);
x_cell = cell(boc_num, 2);
iterations = zeros(boc_num, 2);
outputs = cell(boc_num, 2);

tic;
for id = 1:boc_num
    for lu = 1:2
        % the list of relevant instruments
        subset_list = true(port.m, 1);
        
        subset_list(441:450) = false;
        repl = [false(440, 1); true];
        subset_list(440 + id) = true;
        subport = portsubset(port, subset_list);
        subportlim = portsubset(portlim, subset_list);
        repl_size = sum(repl);
        price_bounds_subset = price_bounds(subset_list, :);
        price_traded = nonreplprice(price_bounds_subset, repl);
        weight_fixed = 3 - 2 * lu;
        
        if lu == 1
            init_lb = -0.1;
        else
            init_lb = -sum(price_bounds(2:6, 1)) - 0.1;
        end
        
        
        options = struct('tol', 1e-3, 'drop_thres', 1, ...
            'init_rprice_lb', init_lb);
        
        [rprice, rprice_lb, weight_final, output] = lsipecpalgo_gurobi( ...
            subport, subportlim, price_traded, repl, weight_fixed, ...
            options);
        out_bounds(id, lu) = rprice * (3 - 2 * lu);
        out_bounds_o(id, lu) = rprice_lb * (3 - 2 * lu);
        weights{id, lu} = weight_final;
        x_cell{id, lu} = output.x;
        iterations(id, lu) = output.iter;
        outputs{id, lu} = output;
        
        if lu == 1
            fprintf('upper bound = %.3f, iter = %d\n', ...
                out_bounds(id, lu), output.iter);
        else
            fprintf('lower bound = %.3f, iter = %d\n', ...
                out_bounds(id, lu), output.iter);
        end
    end
end

compute_time = toc;

save('exp/exp4/rst/ecp.mat');