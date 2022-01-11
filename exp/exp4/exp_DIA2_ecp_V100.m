load('exp/exp4/DIA_sanitized.mat');
load('exp/exp4/exp_DIA2.mat');

prevfile = load('exp/exp4/rst/DIA2_ecp_V(50).mat');

set_id = 4;

[port, portlim] = portcreate(conf);

repl_num = length(DIA_subset_strikes);
out_bounds = zeros(repl_num, 2);
out_bounds_o = zeros(repl_num, 2);
weights = cell(repl_num, 2);
x_cell = cell(repl_num, 2);
iterations = zeros(repl_num, 2);
outputs = cell(repl_num, 2);

tic;
for repl_id = 1:repl_num
    for lu = 1:2
        % the list of relevant instruments
        subset_list = subset_inc_cell{set_id};
        subset_list(index_range.repl(1) - 1 + repl_id) = true;
        repl = false(port.m, 1);
        repl(index_range.repl(1) - 1 + repl_id) = true;
        repl = repl(subset_list);
        repl_size = sum(repl);
        subport = portsubset(port, subset_list);
        subportlim = portsubset(portlim, subset_list);
        price_traded = nonreplprice(price_bounds(subset_list, :), repl);
        weight_fixed = 3 - 2 * lu;

        if lu == 1
            init_lb = -1;
        else
            init_lb = -sum(price_bounds(index_range.call(:, 1), 1) ...
                .* DIA_weights) - 1;
        end


        options = struct('tol', 1e-3, ...
            'drop_thres', 1, 'drop_iter', inf, ...
            'init_rprice_lb', init_lb, 'x_ub', 7000 * ones(conf.n, 1), ...
            'switch_to_simplex', true, 'display', true);

        if repl_id == 1 && lu == 1
            options.init_x = prevfile.x_cell{1, 1};
        elseif repl_id == 1 && lu == 2
            options.init_x = x_cell{repl_id, 1};
        else
            options.init_x = x_cell{repl_id - 1, lu};
        end

        [rprice, rprice_lb, weight_final, output] = lsipecpalgo_gurobi( ...
            subport, subportlim, price_traded, repl, weight_fixed, ...
            options);
        out_bounds(repl_id, lu) = rprice * (3 - 2 * lu);
        out_bounds_o(repl_id, lu) = rprice_lb * (3 - 2 * lu);
        weights{repl_id, lu} = weight_final;
        x_cell{repl_id, lu} = output.x;
        iterations(repl_id, lu) = output.iter;
        outputs{repl_id, lu} = output;

        if lu == 1
            fprintf('upper bound = %.3f, iter = %d\n', ...
                out_bounds(repl_id, lu), output.iter);
        else
            fprintf('lower bound = %.3f, iter = %d\n', ...
                out_bounds(repl_id, lu), output.iter);
        end
    end
end

compute_time = toc;

save('exp/exp4/rst/DIA2_ecp_V(100).mat');