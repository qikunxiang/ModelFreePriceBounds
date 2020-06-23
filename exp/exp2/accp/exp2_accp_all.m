load('exp/exp2/exp2.mat');

[port, portlim] = portcreate(conf);

compute_time = 0;

for setting = 4:-1:1

out_bounds = zeros(51, 2);
out_bounds_o = zeros(51, 2);
weights = cell(51, 2);
x_cell = cell(51, 2);
iterations = zeros(51, 2);
lp_counts = zeros(51, 2);
milp_counts = zeros(51, 2);
outputs = cell(51, 2);

if setting == 1
    prevfile = load('exp/exp2/rst/accp_set2.mat');
elseif setting == 2
    prevfile = load('exp/exp2/rst/accp_set3.mat');
elseif setting == 3
    prevfile = load('exp/exp2/rst/accp_set4.mat');
else
    clear prevfile;
end

tic;
for id = 1:51
    for lu = 1:2
        % the list of relevant instruments
        subset_list = true(port.m, 1);
        
        if setting == 1
            % setting 1: vanilla + basket + spread + rainbow
            subset_list(441:491) = false;
            repl = [false(440, 1); true;];
        elseif setting == 2
            % setting 2: vanilla + basket + spread
            subset_list(375:491) = false;
            repl = [false(374, 1); true];
        elseif setting == 3
            % setting 3: vanilla + basket
            subset_list(177:491) = false;
            repl = [false(176, 1); true];
        else
            % setting 4: vanilla
            subset_list(57:491) = false;
            repl = [false(56, 1); true];
        end
        subset_list(440 + id) = true;
        subport = portsubset(port, subset_list);
        repl_size = sum(repl);
        price_bounds_subset = price_bounds(subset_list, :);
        price_traded = nonreplprice(price_bounds_subset, repl);
        weight_fixed = 3 - 2 * lu;
        
        if lu == 1
            init_lb = -0.1;
            init_ub = sum(price_bounds(3:5, 1));
            
            if id > 1 && ~isempty(outputs{id - 1, 1})
                init_ub = out_bounds(id - 1, 1);
            end
        else
            init_lb = -sum(price_bounds(3:5, 1)) - 0.1;
            init_ub = 0;
        end

        options = struct('tol', 1e-3, 'init_rprice_lb', init_lb, ...
            'init_rprice_ub', init_ub, 'milp_gap', 0.01);
        
        if id > 1
            options.init_x = x_cell{id - 1, lu};
        elseif id == 1 && exist('prevfile', 'var')
            options.init_x = prevfile.outputs{1, lu}.x_hist;
        end
        
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
compute_time = compute_time + toc;

save(sprintf('exp/exp2/rst/accp_set%d.mat', setting));

end