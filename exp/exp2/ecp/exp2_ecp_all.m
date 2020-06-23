load('exp/exp2/exp2.mat');

[port, portlim] = portcreate(conf);

compute_time = 0;

for setting = 4:-1:1

out_bounds = zeros(51, 2);
out_bounds_o = zeros(51, 2);
weights = cell(51, 2);
x_cell = cell(51, 2);
iterations = zeros(51, 2);
outputs = cell(51, 2);

if setting == 1
    prevfile = load('exp/exp2/rst/ecp_set2.mat');
elseif setting == 2
    prevfile = load('exp/exp2/rst/ecp_set3.mat');
elseif setting == 3
    prevfile = load('exp/exp2/rst/ecp_set4.mat');
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
        subportlim = portsubset(portlim, subset_list);
        repl_size = sum(repl);
        price_bounds_subset = price_bounds(subset_list, :);
        price_traded = nonreplprice(price_bounds_subset, repl);
        weight_fixed = 3 - 2 * lu;
        
        if lu == 1
            init_lb = -0.1;
        else
            init_lb = -sum(price_bounds(3:5, 1)) - 0.1;
        end

        
        options = struct('tol', 1e-3, 'drop_thres', 1, ...
            'init_rprice_lb', init_lb);
        if id > 1
            options.init_x = x_cell{id - 1, lu};
            if lu == 1
                options.init_lp_model = init_lp_u;
            else
                options.init_lp_model = init_lp_l;
            end
        elseif id == 1 && exist('prevfile', 'var')
            options.init_x = prevfile.x_cell{1, lu};
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
            init_lp_u = output.init_lp_model;
            fprintf('option %d, upper bound = %.3f, iter = %d\n', id, ...
                out_bounds(id, lu), output.iter);
        else
            init_lp_l = output.init_lp_model;
            fprintf('option %d, lower bound = %.3f, iter = %d\n', id, ...
                out_bounds(id, lu), output.iter);
        end
    end
end
compute_time = compute_time + toc;

save(sprintf('exp/exp2/rst/ecp_set%d.mat', setting));

end