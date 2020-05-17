function [port, portlim] = portcreate(conf, use_sparse)
% Converting a portfolio of stocks and options to a continuous piecewise
% linear function
% Input:
%       conf: structure with the following fields (some are optional)
%       conf.n: number of stocks
%       conf.call: cell array containing strikes of vanilla call options
%       conf.put: cell array containing strikes of vanilla call options
%       conf.cbask.W: matrix containing weights of basket call options
%       conf.cbask.k: cell array containing strikes of basket call options
%       conf.pbask.W: matrix containing weights of basket put options
%       conf.pbask.k: cell array containing strikes of basket put options
%       conf.cmax.L: logical matrix containing the included stocks of
%                    call-on-max
%       conf.cmax.k: cell array containing strikes of call-on-max
%       conf.cmin.L: logical matrix containing the included stocks of
%                    call-on-min
%       conf.cmin.k: cell array containing strikes of call-on-min
%       conf.pmax.L: logical matrix containing the included stocks of
%                    put-on-max
%       conf.pmax.k: cell array containing strikes of put-on-max
%       conf.pmin.L: logical matrix containing the included stocks of
%                    put-on-min
%       conf.pmin.k: cell array containing strikes of put-on-min
%       conf.boc.L: logical matrix containing the included stocks of
%                   best-of-calls
%       conf.boc.k: cell array containing strikes of best-of-calls
%       use_sparse: logical, indicating whether to convert everything to
%                   sparse
% Output:
%       port: structure containing the following fields
%       port.aff.C: coefficient matrix for the affine part
%       port.aff.c: coefficient vector for the constant intercept
%       port.hp.A: matrix for the half-plane part
%       port.hp.b: constants for the half-plane part
%       port.hp.C: coefficient matrix for the half-plane part
%       port.gen.A: matrix for the general part
%       port.gen.b: constants for the general part
%       port.gen.grp: grouping for the general part
%       port.gen.C: coefficient matrix for the general part
%       portlim: same as port, but used for evaluating the limit on rays
%           and may be simplified further

if ~exist('use_sparse', 'var') || isempty(use_sparse)
    use_sparse = false;
end

n = conf.n;
m = 1 + n;

if isfield(conf, 'call')
    m = m + sum(cellfun(@length, conf.call));
end

if isfield(conf, 'put')
    m = m + sum(cellfun(@length, conf.put));
end

if isfield(conf, 'cbask')
    m = m + sum(cellfun(@length, conf.cbask.k));
end

if isfield(conf, 'pbask')
    m = m + sum(cellfun(@length, conf.pbask.k));
end

if isfield(conf, 'cmax')
    m = m + sum(cellfun(@length, conf.cmax.k));
end

if isfield(conf, 'cmin')
    m = m + sum(cellfun(@length, conf.cmin.k));
end

if isfield(conf, 'pmax')
    m = m + sum(cellfun(@length, conf.pmax.k));
end

if isfield(conf, 'pmin')
    m = m + sum(cellfun(@length, conf.pmin.k));
end

if isfield(conf, 'boc')
    m = m + sum(cellfun(@(x)(size(x, 1)), conf.boc.k));
end

port = struct;
port.n = n;
port.m = m;
portlim = struct;
portlim.n = n;
portlim.m = m;

% affine part
port.aff = struct;
portlim.aff = struct;
% stocks
port.aff.C = [zeros(n, 1), eye(n), zeros(n, m - 1 - n)];
port.aff.c = [1, zeros(1, m - 1)];
portlim.aff.C = port.aff.C;
portlim.aff.c = zeros(1, m);

% half plane part

% vanilla call options
if isfield(conf, 'call')
    call_A = repelem(eye(n), cellfun(@length, conf.call), 1);
    call_b = -vertcat(conf.call{:});
else
    call_A = zeros(0, n);
    call_b = zeros(0, 1);
end

% vanilla put options
if isfield(conf, 'put')
    put_A = repelem(-eye(n), cellfun(@length, conf.put), 1);
    put_b = vertcat(conf.put{:});
else
    put_A = zeros(0, n);
    put_b = zeros(0, 1);
end

% basket call options
if isfield(conf, 'cbask')
    cbask_A = repelem(conf.cbask.W, cellfun(@length, conf.cbask.k), 1);
    cbask_b = -vertcat(conf.cbask.k{:});
else
    cbask_A = zeros(0, n);
    cbask_b = zeros(0, 1);
end

% basket put options
if isfield(conf, 'pbask')
    pbask_A = repelem(-conf.pbask.W, cellfun(@length, conf.pbask.k), 1);
    pbask_b = vertcat(conf.pbask.k{:});
else
    pbask_A = zeros(0, n);
    pbask_b = zeros(0, 1);
end

hp_A = [call_A; put_A; cbask_A; pbask_A];
hp_b = [call_b; put_b; cbask_b; pbask_b];
hp_num = length(hp_b);
hp_C = [zeros(hp_num, 1 + n), eye(hp_num), ...
    zeros(hp_num, m - 1 - n - hp_num)];


% simplify the half-plane part to eliminate redundant functions via the
% call-put parity
hp_mat_A = zeros(hp_num, n);
hp_mat_b = zeros(hp_num, 1);
hp_mat_C = zeros(hp_num, m);
next_hp_index = 1;

for i = 1:hp_num
    cur_A = hp_A(i, :);
    cur_b = hp_b(i);
    cur_C = hp_C(i, :);
    dup = false;
    
    for j = 1:(next_hp_index - 1)
        % if a call and a put option have the same weights and strikes, the
        % put option can be replaced by a call option minus the index
        if (hp_mat_b(j) + cur_b == 0) ...
                && all(hp_mat_A(j, :) + cur_A == 0)
            hp_mat_C(j, :) = hp_mat_C(j, :) + cur_C;
            port.aff.C = port.aff.C + cur_C .* cur_A';
            port.aff.c = port.aff.c + cur_C * cur_b;
            dup = true;
            break;
        end
    end
    
    if ~dup
        hp_mat_A(next_hp_index, :) = cur_A;
        hp_mat_b(next_hp_index) = cur_b;
        hp_mat_C(next_hp_index, :) = cur_C;
        next_hp_index = next_hp_index + 1;
    end
end

if next_hp_index > 1
    port.hp = struct;
    port.hp.A = hp_mat_A(1:next_hp_index - 1, :);
    port.hp.b = hp_mat_b(1:next_hp_index - 1);
    port.hp.C = hp_mat_C(1:next_hp_index - 1, :);
end

% simplify the half-plane part for limit on rays
lhp_mat_A = zeros(hp_num, n);
lhp_mat_C = zeros(hp_num, m);
next_lhp_index = 1;

for i = 1:hp_num
    cur_A = hp_A(i, :);
    cur_C = hp_C(i, :);
    
    % if the weight is in the positive quadrant, the limit of the function
    % is equal to the linear function
    if all(cur_A >= 0)
        portlim.aff.C = portlim.aff.C + cur_C .* cur_A';
        continue;
    end
    
    % if the weight is in the negative quadrant, the limit of the function
    % is 0 in every direction
    if all(cur_A <= 0)
        continue;
    end
    
    dup = false;
    
    for j = 1:(next_lhp_index - 1)
        % if two options have the same weight, their limits can be combined
        if all(lhp_mat_A(j, :) == cur_A)
            lhp_mat_C(j, :) = lhp_mat_C(j, :) + cur_C;
            dup = true;
            break;
        end
        
        % if two options have the opposite weight, the sum of their limits
        % is a linear function
        if all(lhp_mat_A(j, :) + cur_A == 0)
            lhp_mat_C(j, :) = lhp_mat_C(j, :) + cur_C;
            portlim.aff.C = portlim.aff.C + cur_C .* cur_A';
            dup = true;
            break;
        end
    end
    
    if ~dup
        lhp_mat_A(next_lhp_index, :) = cur_A;
        lhp_mat_C(next_lhp_index, :) = cur_C;
        next_lhp_index = next_lhp_index + 1;
    end
end

if next_lhp_index > 1
    portlim.hp = struct;
    portlim.hp.A = lhp_mat_A(1:next_lhp_index - 1, :);
    portlim.hp.b = zeros(next_lhp_index - 1, 1);
    portlim.hp.C = lhp_mat_C(1:next_lhp_index - 1, :);
end

% general part (optional)
if isfield(conf, 'cmax') || isfield(conf, 'cmin') ...
        || isfield(conf, 'pmax') || isfield(conf, 'pmin') ...
        || isfield(conf, 'boc')
    I = eye(n);
    grp_index_max = 0;
    opt_index_max = 0;
    
    % call-on-max
    if isfield(conf, 'cmax')
        cmax_num = size(conf.cmax.L, 1);
        cmax_A = cell(cmax_num, 1);
        cmax_b = cell(cmax_num, 1);
        cmax_grp = cell(cmax_num, 1);
        cmax_C = cell(cmax_num, 1);
        
        for i = 1:cmax_num
            s_num = sum(conf.cmax.L(i, :));
            assert(s_num > 0, 'invalid call-on-max');
            strike_num = length(conf.cmax.k{i});
            cmax_A{i} = repmat([I(logical(conf.cmax.L(i, :)), :); ...
                zeros(1, n)], strike_num, 1);
            b_temp = [-ones(s_num, 1); 0] .* conf.cmax.k{i}';
            cmax_b{i} = b_temp(:);
            cmax_grp{i} = repelem((grp_index_max + (1:strike_num))', ...
                s_num + 1, 1);
            cmax_C{i} = [zeros(strike_num, 1 + n + hp_num), ...
                zeros(strike_num, opt_index_max), eye(strike_num), ...
                zeros(strike_num, m - 1 - n - hp_num - opt_index_max ...
                - strike_num)];
            
            grp_index_max = grp_index_max + strike_num;
            opt_index_max = opt_index_max + strike_num;
        end
        
        cmax_A_v = vertcat(cmax_A{:});
        cmax_b_v = vertcat(cmax_b{:});
        cmax_grp_v = vertcat(cmax_grp{:});
        cmax_C_v = vertcat(cmax_C{:});
    else
        cmax_A_v = zeros(0, n);
        cmax_b_v = zeros(0, 1);
        cmax_grp_v = zeros(0, 1);
        cmax_C_v = zeros(0, m);
    end
    
    % call-on-min
    if isfield(conf, 'cmin')
        cmin_num = size(conf.cmin.L, 1);
        cmin_A = cell(cmin_num, 1);
        cmin_b = cell(cmin_num, 1);
        cmin_grp = cell(cmin_num, 1);
        cmin_C = cell(cmin_num, 1);
        
        for i = 1:cmin_num
            s_num = sum(conf.cmin.L(i, :));
            assert(s_num > 0, 'invalid call-on-min');
            strike_num = length(conf.cmin.k{i});
            I_sub = I(logical(conf.cmin.L(i, :)), :);
            cmin_A{i} = repmat([-I_sub; zeros(1, n); -I_sub], ...
                strike_num, 1);
            b_temp = [ones(s_num, 1); 0; zeros(s_num, 1)] ...
                .* conf.cmin.k{i}';
            cmin_b{i} = b_temp(:);
            cmin_grp{i} = repelem((grp_index_max ...
                + (1:2 * strike_num))', ...
                repmat([s_num + 1; s_num], strike_num, 1), 1);
            cmin_C{i} = repelem([zeros(strike_num, 1 + n + hp_num), ...
                zeros(strike_num, opt_index_max), eye(strike_num), ...
                zeros(strike_num, m - 1 - n - hp_num - opt_index_max ...
                - strike_num)], 2, 1) ...
                .* repmat([1; -1], strike_num, 1);
            port.aff.c = port.aff.c + conf.cmin.k{i}' ...
                * cmin_C{i}(2:2:end, :);
            
            grp_index_max = grp_index_max + 2 * strike_num;
            opt_index_max = opt_index_max + strike_num;
        end
        
        cmin_A_v = vertcat(cmin_A{:});
        cmin_b_v = vertcat(cmin_b{:});
        cmin_grp_v = vertcat(cmin_grp{:});
        cmin_C_v = vertcat(cmin_C{:});
    else
        cmin_A_v = zeros(0, n);
        cmin_b_v = zeros(0, 1);
        cmin_grp_v = zeros(0, 1);
        cmin_C_v = zeros(0, m);
    end
    
    % put-on-max
    if isfield(conf, 'pmax')
        pmax_num = size(conf.pmax.L, 1);
        pmax_A = cell(pmax_num, 1);
        pmax_b = cell(pmax_num, 1);
        pmax_grp = cell(pmax_num, 1);
        pmax_C = cell(pmax_num, 1);
        
        for i = 1:pmax_num
            s_num = sum(conf.pmax.L(i, :));
            assert(s_num > 0, 'invalid put-on-max');
            strike_num = length(conf.pmax.k{i});
            I_sub = I(logical(conf.pmax.L(i, :)), :);
            pmax_A{i} = repmat([I_sub; zeros(1, n); I_sub], ...
                strike_num, 1);
            b_temp = [-ones(s_num, 1); 0; zeros(s_num, 1)] ...
                .* conf.pmax.k{i}';
            pmax_b{i} = b_temp(:);
            pmax_grp{i} = repelem((grp_index_max ...
                + (1:2 * strike_num))', ...
                repmat([s_num + 1; s_num], strike_num, 1), 1);
            pmax_C{i} = repelem([zeros(strike_num, 1 + n + hp_num), ...
                zeros(strike_num, opt_index_max), eye(strike_num), ...
                zeros(strike_num, m - 1 - n - hp_num - opt_index_max ...
                - strike_num)], 2, 1) ...
                .* repmat([1; -1], strike_num, 1);
            port.aff.c = port.aff.c - conf.pmax.k{i}' ...
                * pmax_C{i}(2:2:end, :);
            
            grp_index_max = grp_index_max + 2 * strike_num;
            opt_index_max = opt_index_max + strike_num;
        end
        
        pmax_A_v = vertcat(pmax_A{:});
        pmax_b_v = vertcat(pmax_b{:});
        pmax_grp_v = vertcat(pmax_grp{:});
        pmax_C_v = vertcat(pmax_C{:});
    else
        pmax_A_v = zeros(0, n);
        pmax_b_v = zeros(0, 1);
        pmax_grp_v = zeros(0, 1);
        pmax_C_v = zeros(0, m);
    end
    
    % put-on-min
    if isfield(conf, 'pmin')
        pmin_num = size(conf.pmin.L, 1);
        pmin_A = cell(pmin_num, 1);
        pmin_b = cell(pmin_num, 1);
        pmin_grp = cell(pmin_num, 1);
        pmin_C = cell(pmin_num, 1);
        
        for i = 1:pmin_num
            s_num = sum(conf.pmin.L(i, :));
            assert(s_num > 0, 'invalid put-on-min');
            strike_num = length(conf.pmin.k{i});
            pmin_A{i} = repmat([-I(logical(conf.pmin.L(i, :)), :); ...
                zeros(1, n)], strike_num, 1);
            b_temp = [ones(s_num, 1); 0] .* conf.pmin.k{i}';
            pmin_b{i} = b_temp(:);
            pmin_grp{i} = repelem((grp_index_max + (1:strike_num))', ...
                s_num + 1, 1);
            pmin_C{i} = [zeros(strike_num, 1 + n + hp_num), ...
                zeros(strike_num, opt_index_max), eye(strike_num), ...
                zeros(strike_num, m - 1 - n - hp_num - opt_index_max ...
                - strike_num)];
            
            grp_index_max = grp_index_max + strike_num;
            opt_index_max = opt_index_max + strike_num;
        end
        
        pmin_A_v = vertcat(pmin_A{:});
        pmin_b_v = vertcat(pmin_b{:});
        pmin_grp_v = vertcat(pmin_grp{:});
        pmin_C_v = vertcat(pmin_C{:});
    else
        pmin_A_v = zeros(0, n);
        pmin_b_v = zeros(0, 1);
        pmin_grp_v = zeros(0, 1);
        pmin_C_v = zeros(0, m);
    end
    
    % best-of-calls
    if isfield(conf, 'boc')
        boc_num = size(conf.boc.L, 1);
        boc_A = cell(boc_num, 1);
        boc_b = cell(boc_num, 1);
        boc_grp = cell(boc_num, 1);
        boc_C = cell(boc_num, 1);
        
        for i = 1:boc_num
            s_num = sum(conf.boc.L(i, :));
            assert(s_num > 0, 'invalid best-of-calls');
            strike_num = size(conf.boc.k{i}, 1);
            boc_A{i} = repmat([I(logical(conf.boc.L(i, :)), :); ...
                zeros(1, n)], strike_num, 1);
            b_temp = [-conf.boc.k{i}'; zeros(1, strike_num)];
            boc_b{i} = b_temp(:);
            boc_grp{i} = repelem((grp_index_max + (1:strike_num))', ...
                s_num + 1, 1);
            boc_C{i} = [zeros(strike_num, 1 + n + hp_num), ...
                zeros(strike_num, opt_index_max), eye(strike_num), ...
                zeros(strike_num, m - 1 - n - hp_num - opt_index_max ...
                - strike_num)];
            
            grp_index_max = grp_index_max + strike_num;
            opt_index_max = opt_index_max + strike_num;
        end
        
        boc_A_v = vertcat(boc_A{:});
        boc_b_v = vertcat(boc_b{:});
        boc_grp_v = vertcat(boc_grp{:});
        boc_C_v = vertcat(boc_C{:});
    else
        boc_A_v = zeros(0, n);
        boc_b_v = zeros(0, 1);
        boc_grp_v = zeros(0, 1);
        boc_C_v = zeros(0, m);
    end
    
    gen_A = [cmax_A_v; cmin_A_v; pmax_A_v; pmin_A_v; boc_A_v];
    gen_b = [cmax_b_v; cmin_b_v; pmax_b_v; pmin_b_v; boc_b_v];
    gen_grp = [cmax_grp_v; cmin_grp_v; pmax_grp_v; pmin_grp_v; boc_grp_v];
    gen_C = [cmax_C_v; cmin_C_v; pmax_C_v; pmin_C_v; boc_C_v];
    
    % simplify the general part to eliminate redundant functions that are
    % exactly the same (as can occur between call-on-max and put-on-max, or
    % between call-on-min and put-on-min)
    next_grp_index = 1;
    grp_num = max(gen_grp);
    gen_cell_A = cell(grp_num, 1);
    gen_cell_b = cell(grp_num, 1);
    gen_cell_grp = cell(grp_num, 1);
    gen_cell_C = cell(grp_num, 1);
    
    for i = 1:grp_num
        list = gen_grp == i;
        cur_A = gen_A(list, :);
        cur_b = gen_b(list);
        cur_C = gen_C(i, :);
        dup = false;
        
        for j = 1:(next_grp_index - 1)
            % if two general CPWL functions have the exact same weights and
            % intercepts, they can be combined into a single CPWL function
            if length(cur_b) == length(gen_cell_b{j}) ...
                    && all(cur_b == gen_cell_b{j}) ...
                    && all(all(cur_A == gen_cell_A{j}))
                gen_cell_C{j} = gen_cell_C{j} + cur_C;
                dup = true;
                break;
            end
        end
        
        if ~dup
            gen_cell_A{next_grp_index} = cur_A;
            gen_cell_b{next_grp_index} = cur_b;
            gen_cell_C{next_grp_index} = cur_C;
            gen_cell_grp{next_grp_index} = next_grp_index ...
                * ones(length(cur_b), 1);
            next_grp_index = next_grp_index + 1;
        end
    end
    
    if next_grp_index > 1
        port.gen = struct;
        port.gen.A = vertcat(gen_cell_A{:});
        port.gen.b = vertcat(gen_cell_b{:});
        port.gen.grp = vertcat(gen_cell_grp{:});
        port.gen.C = vertcat(gen_cell_C{:});
    end
    
    % simplify the general part for limit on rays
    next_lgrp_index = 1;
    lgen_cell_A = cell(grp_num, 1);
    lgen_cell_grp = cell(grp_num, 1);
    lgen_cell_C = cell(grp_num, 1);
    
    for i = 1:grp_num
        list = gen_grp == i;
        cur_A = gen_A(list, :);
        cur_C = gen_C(i, :);
        
        % check for any pairwise dominance relations
        cur_num = size(cur_A, 1);
        cur_rel = zeros(cur_num);
        cur_max_row = 0;
        for l = 1:cur_num
            if all(all(cur_A(l, :) - cur_A >= 0))
                cur_max_row = l;
                break;
            end
            cur_rel(l, :) = -all(cur_A(l, :) - cur_A <= 0, 2)';
            cur_rel(l, l) = 0;
        end
        
        if cur_max_row > 0
            % if one row dominates the rest, the limit of the function is a
            % linear function with weight equal to this row
            portlim.aff.C = portlim.aff.C + cur_C ...
                .* cur_A(cur_max_row, :)';
            continue;
        else
            % if one row is dominated by at least one other row, it will
            % not be attained as the limit
            cur_dominated = any(cur_rel == -1, 2);
            cur_A = cur_A(~cur_dominated, :);
        end
        
        dup = false;
        
        for j = 1:(next_lgrp_index - 1)
            % if two general CPWL functions have the exact same weights,
            % their limit can be combined into a single CPWL function
            if size(cur_A, 1) == size(lgen_cell_A{j}, 1) ...
                    && all(all(cur_A == lgen_cell_A{j}))
                lgen_cell_C{j} = lgen_cell_C{j} + cur_C;
                dup = true;
                break;
            end
        end
        
        if ~dup
            lgen_cell_A{next_lgrp_index} = cur_A;
            lgen_cell_C{next_lgrp_index} = cur_C;
            lgen_cell_grp{next_lgrp_index} = next_lgrp_index ...
                * ones(size(cur_A, 1), 1);
            next_lgrp_index = next_lgrp_index + 1;
        end
    end
    
    if next_lgrp_index > 1
        portlim.gen = struct;
        portlim.gen.A = vertcat(lgen_cell_A{:});
        portlim.gen.b = zeros(size(portlim.gen.A, 1), 1);
        portlim.gen.grp = vertcat(lgen_cell_grp{:});
        portlim.gen.C = vertcat(lgen_cell_C{:});
    end
end

% add index to the general part

if isfield(port, 'gen')
    grp = port.gen.grp;
    index = zeros(length(grp), 1);
    
    for i = 1:max(grp)
        index(grp == i) = 1:sum(grp == i);
    end
    port.gen.index = index;
end

if isfield(portlim, 'gen')
    grp = portlim.gen.grp;
    index = zeros(length(grp), 1);
    
    for i = 1:max(grp)
        index(grp == i) = 1:sum(grp == i);
    end
    portlim.gen.index = index;
end

if use_sparse
    port.aff.C = sparse(port.aff.C);
    port.aff.c = sparse(port.aff.c);
    
    if isfield(port, 'hp')
        port.hp.A = sparse(port.hp.A);
        port.hp.C = sparse(port.hp.C);
    end
    
    if isfield(port, 'gen')
        port.gen.A = sparse(port.gen.A);
        port.gen.C = sparse(port.gen.C);
    end
end

end

