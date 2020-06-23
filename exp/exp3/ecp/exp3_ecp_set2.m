load('exp/exp3/exp3.mat');

[port, ~] = portcreate(conf);

strike_num = 11;

out_bounds = zeros(strike_num, 2);
out_bounds_o = zeros(strike_num, 2);
weights = cell(strike_num, 2);
x_cell = cell(strike_num, 2);
iterations = zeros(strike_num, 2);
outputs = cell(strike_num, 2);

tic;
for id = 1:strike_num
    for lu = 1:2
        
        % the list of relevant instruments
        subset_list = true(port.m, 1);
        
        subset_list(402:412) = false;
        repl = [false(401, 1); true];
        
        subset_list(401 + id) = true;
        subport = portsubset(port, subset_list);
        repl_size = sum(repl);
        price_bounds_subset = price_bounds(subset_list, :);
        price_traded = nonreplprice(price_bounds_subset, repl);
        weight_fixed = 3 - 2 * lu;
        
        if lu == 1
            init_lb = -1;
        else
            init_lb = -min(price_bounds(2:51, 1)) - 1;
            
            if id > 1 && ~isempty(outputs{id - 1, 1})
                init_lb = -out_bounds(id - 1, 2) - 1;
            end
        end

        
        options = struct('tol', 1e-3, 'drop_thres', 1, ...
            'init_rprice_lb', init_lb);
        if id > 1
            options.init_x = x_cell{id - 1, lu};
        elseif id == 1 && lu == 2
            options.init_x = x_cell{1, 1};
        end
        
        [rprice, rprice_lb, weight_final, output] = lsipecpalgo_gurobi( ...
            subport, [], price_traded, repl, weight_fixed, ...
            options);
        out_bounds(id, lu) = rprice * (3 - 2 * lu);
        out_bounds_o(id, lu) = rprice_lb * (3 - 2 * lu);
        weights{id, lu} = weight_final;
        x_cell{id, lu} = output.x;
        iterations(id, lu) = output.iter;
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
compute_time = toc;

save('exp/exp3/rst/ecp_set2.mat');