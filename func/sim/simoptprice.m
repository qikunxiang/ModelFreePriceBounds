function [price_bounds, price_all] = simoptprice(conf, sim_num, ...
    marg, dep, ub)
% Simulate various option prices under a list of candidate models in which 
% the marginal distributions are log-normal and the dependence structure 
% is t-copula
% Inputs: 
%       conf: portfolio configuration structure
%       sim_num: number of random simulations to perform
%       marg: cell array containing marginal information
%       dep: cell array containiing dependence information
%       ub: upper bound on the support of the measure (default is inf)
% Outputs:
%       price_bounds: matrix with 2 columns where column 1 represents upper
%           bounds and column 2 represents lower bounds
%       price_all: prices under all models

if ~exist('ub', 'var') || isempty(ub)
    ub = inf(conf.n, 1);
end

price_all = struct;

marg_num = length(marg);
dep_num = length(dep);

% compute the forward prices and vanilla option prices
forward_mat = zeros(conf.n, marg_num);
for i = 1:marg_num
    forward_mat(:, i) = lognorm_partialexp(marg{i}.mu, marg{i}.sig2, ...
        0, ub(i), 1, 0);
end
forward_prices = [max(forward_mat, [], 2), min(forward_mat, [], 2)];
price_all.forward = forward_mat;

if isfield(conf, 'call')
    call_cell = cell(conf.n, 1);
    call_all_cell = cell(conf.n, 1);
    for i = 1:conf.n
        call_n_mat = zeros(length(conf.call{i}), marg_num);
        for j = 1:marg_num
            call_n_mat(:, j) = lognorm_partialexp(marg{j}.mu(i), ...
                marg{j}.sig2(i), conf.call{i}, ub(i), 1, -conf.call{i});
        end
        call_cell{i} = [max(call_n_mat, [], 2), min(call_n_mat, [], 2)];
        call_all_cell{i} = call_n_mat;
    end
    call_prices = vertcat(call_cell{:});
    price_all.call = vertcat(call_all_cell{:});
else
    call_prices = [];
end

if isfield(conf, 'put')
    put_cell = cell(conf.n, 1);
    put_all_cell = cell(conf.n, 1);
    for i = 1:conf.n
        put_n_mat = zeros(length(conf.put{i}), marg_num);
        for j = 1:marg_num
            put_n_mat(:, j) = lognorm_partialexp(marg{j}.mu(i), ...
                marg{j}.sig2(i), 0, min(conf.put{i}, ub(i)), ...
                -1, conf.put{i});
        end
        put_cell{i} = [max(put_n_mat, [], 2), min(put_n_mat, [], 2)];
        put_all_cell{i} = put_n_mat;
    end
    put_prices = vertcat(put_cell{:});
    price_all.put = vertcat(put_all_cell{:});
else
    put_prices = [];
end

% use Monte Carlo to approximate the price bounds of basket options and
% rainbow options
if exist('dep', 'var') && (isfield(conf, 'cbask') ...
        || isfield(conf, 'pbask') || isfield(conf, 'cmax') ...
        || isfield(conf, 'cmin') || isfield(conf, 'pmax') ...
        || isfield(conf, 'pmin')) || isfield(conf, 'boc')
    sce_num = marg_num * dep_num;

    % generate samples of copula for each setting
    c_cell = cell(dep_num, 1);
    for i = 1:dep_num
        cur_dep = dep{i};
        c_cell{i} = copularnd('t', cur_dep.rho, cur_dep.nu, sim_num);
    end
    
    % generate complete samples
    X_cell = cell(sce_num, 1);
    for i = 1:dep_num
        for j = 1:marg_num
            norm_const = normcdf((log(ub) - marg{j}.mu) ...
                ./ sqrt(marg{j}.sig2));
            
            X = c_cell{i};
            for k = 1:conf.n
                X(:, k) = logninv(X(:, k) * norm_const(k), ...
                    marg{j}.mu(k), sqrt(marg{j}.sig2(k)));
            end
            X_cell{(i - 1) * marg_num + j} = X;
        end
    end
    
    % compute the option prices
    if isfield(conf, 'cbask')
        cbask_num = length(conf.cbask.k);
        cbask_cell = cell(cbask_num, 1);
        cbask_all_cell = cell(cbask_num, 1);
        
        for i = 1:cbask_num
            stk_num = length(conf.cbask.k{i});
            cbask_mat = zeros(stk_num, sce_num);
            
            for j = 1:sce_num
                X = X_cell{j};
                cbask_mat(:, j) = mean(max(conf.cbask.W(i, :) * X' ...
                    - conf.cbask.k{i}, 0), 2);
            end
            
            cbask_cell{i} = [max(cbask_mat, [], 2), min(cbask_mat, [], 2)];
            cbask_all_cell{i} = cbask_mat;
        end
        
        cbask_prices = vertcat(cbask_cell{:});
        price_all.cbask = vertcat(cbask_all_cell{:});
    else
        cbask_prices = [];
    end
    
    if isfield(conf, 'pbask')
        pbask_num = length(conf.pbask.k);
        pbask_cell = cell(pbask_num, 1);
        pbask_all_cell = cell(pbask_num, 1);
        
        for i = 1:pbask_num
            stk_num = length(conf.pbask.k{i});
            pbask_mat = zeros(stk_num, sce_num);
            
            for j = 1:sce_num
                X = X_cell{j};
                pbask_mat(:, j) = mean(max(conf.pbask.k{i} ...
                    - conf.pbask.W(i, :) * X' , 0), 2);
            end
            
            pbask_cell{i} = [max(pbask_mat, [], 2), min(pbask_mat, [], 2)];
            pbask_all_cell{i} = pbask_mat;
        end
        
        pbask_prices = vertcat(pbask_cell{:});
        price_all.pbask = vertcat(pbask_all_cell{:});
    else
        pbask_prices = [];
    end
    
    if isfield(conf, 'cmax')
        cmax_num = length(conf.cmax.k);
        cmax_cell = cell(cmax_num, 1);
        cmax_all_cell = cell(cmax_num, 1);
        
        for i = 1:cmax_num
            stk_num = length(conf.cmax.k{i});
            cmax_mat = zeros(stk_num, sce_num);
            
            for j = 1:sce_num
                X = X_cell{j};
                cmax_mat(:, j) = mean(max(max(X(:, ...
                    conf.cmax.L(i, :) ~= 0), [], 2)' ...
                    - conf.cmax.k{i}, 0), 2);
            end
            
            cmax_cell{i} = [max(cmax_mat, [], 2), min(cmax_mat, [], 2)];
            cmax_all_cell{i} = cmax_mat;
        end
        
        cmax_prices = vertcat(cmax_cell{:});
        price_all.cmax = vertcat(cmax_all_cell{:});
    else
        cmax_prices = [];
    end
    
    if isfield(conf, 'cmin')
        cmin_num = length(conf.cmin.k);
        cmin_cell = cell(cmin_num, 1);
        cmin_all_cell = cell(cmin_num, 1);
        
        for i = 1:cmin_num
            stk_num = length(conf.cmin.k{i});
            cmin_mat = zeros(stk_num, sce_num);
            
            for j = 1:sce_num
                X = X_cell{j};
                cmin_mat(:, j) = mean(max(min(X(:, ...
                    conf.cmin.L(i, :) ~= 0), [], 2)' ...
                    - conf.cmin.k{i}, 0), 2);
            end
            
            cmin_cell{i} = [max(cmin_mat, [], 2), min(cmin_mat, [], 2)];
            cmin_all_cell{i} = cmin_mat;
        end
        
        cmin_prices = vertcat(cmin_cell{:});
        price_all.cmin = vertcat(cmin_all_cell{:});
    else
        cmin_prices = [];
    end
    
    if isfield(conf, 'pmax')
        pmax_num = length(conf.pmax.k);
        pmax_cell = cell(pmax_num, 1);
        pmax_all_cell = cell(pmax_num, 1);
        
        for i = 1:pmax_num
            stk_num = length(conf.pmax.k{i});
            pmax_mat = zeros(stk_num, sce_num);
            
            for j = 1:sce_num
                X = X_cell{j};
                pmax_mat(:, j) = mean(max(conf.pmax.k{i} - max(X(:, ...
                    conf.pmax.L(i, :) ~= 0), [], 2)', 0), 2);
            end
            
            pmax_cell{i} = [max(pmax_mat, [], 2), min(pmax_mat, [], 2)];
            pmax_all_cell{i} = pmax_mat;
        end
        
        pmax_prices = vertcat(pmax_cell{:});
        price_all.pmax = vertcat(pmax_all_cell{:});
    else
        pmax_prices = [];
    end
    
    if isfield(conf, 'pmin')
        pmin_num = length(conf.pmin.k);
        pmin_cell = cell(pmin_num, 1);
        pmin_all_cell = cell(pmin_num, 1);
        
        for i = 1:pmin_num
            stk_num = length(conf.pmin.k{i});
            pmin_mat = zeros(stk_num, sce_num);
            
            for j = 1:sce_num
                X = X_cell{j};
                pmin_mat(:, j) = mean(max(conf.pmin.k{i} - min(X(:, ...
                    conf.pmin.L(i, :) ~= 0), [], 2)', 0), 2);
            end
            
            pmin_cell{i} = [max(pmin_mat, [], 2), min(pmin_mat, [], 2)];
            pmin_all_cell{i} = pmin_mat;
        end
        
        pmin_prices = vertcat(pmin_cell{:});
        price_all.pmin = vertcat(pmin_all_cell{:});
    else
        pmin_prices = [];
    end
    
    if isfield(conf, 'boc')
        boc_num = length(conf.boc.L);
        boc_cell = cell(boc_num, 1);
        boc_all_cell = cell(boc_num, 1);
        
        for i = 1:boc_num
            stk_num = size(conf.boc.k{i}, 1);
            boc_mat = zeros(stk_num, sce_num);
            
            for j = 1:sce_num
                for k = 1:stk_num
                    X = X_cell{j};
                    boc_mat(k, j) = mean(max(max( ...
                        X * conf.boc.L{i}' ...
                        - conf.boc.k{i}(k, :), [], 2), 0), 1);
                end
            end
            
            boc_cell{i} = [max(boc_mat, [], 2), min(boc_mat, [], 2)];
            boc_all_cell{i} = boc_mat;
        end
        
        boc_prices = vertcat(boc_cell{:});
        price_all.boc = vertcat(boc_all_cell{:});
    else
        boc_prices = [];
    end
else
    cbask_prices = [];
    pbask_prices = [];
    cmax_prices = [];
    cmin_prices = [];
    pmax_prices = [];
    pmin_prices = [];
    boc_prices = [];
end

price_bounds = [1, 1; forward_prices; call_prices; put_prices; ...
    cbask_prices; pbask_prices; cmax_prices; cmin_prices; ...
    pmax_prices; pmin_prices; boc_prices];

end

