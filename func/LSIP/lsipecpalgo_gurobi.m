function [rprice, rprice_lb, weight_vec, output] = lsipecpalgo_gurobi( ...
    port, portlim, price_bounds, repl, weight_fixed, options)
% External cutting plane algorithm that computes the robust upper bound of
% the price of a portfolio. Uses Gurobi as the solver. 
% Inputs:
%       port: the portfolio returned by function portcreate
%       portlim: (optional) the limit portfolio returned by function 
%           portcreate; when not supplied, asymptotic constraints are
%           dropped
%       price_bounds: the upper and lower bounds of known derivatives
%       repl: logical vector specifying the portfolio to be
%           super-replicated
%       weight_fixed: vector of weights in the portfolio to be
%           super-replicated
%       options: structure containing options of the algorithm
%           tol: positive tolerance for termination
%           drop_thres: positive threshold to drop possibly redundant
%               constraints
%           drop_iter: frequency of dropping constraints, if set to Inf,
%               the constraints will only be dropped in the first iteration
%           init_lp_model: (optional) initial LP model
%           init_x: (optional) initial set of x, each column is one set of
%               x
%           init_rprice_lb: initial lower bound of the robust price
%           x_ub: upper bounds on the asset prices used in the formulation
%                 of the MILP
%           switch_to_simplex: boolean indicating whether to switch to dual
%               simplex method once the lower bound has been updated
%           display: boolean indicating whether to display Gurobi output
% Outputs:
%       rprice: robust upper bound on the price of the portfolio
%       weight_vec: complete weight vector of the non-negative portfolio
%       output: structure containing additional information:
%           iter: number of iterations
%           lp_count: number of LP solved
%           milp_count: number of MILP solved
%           x: matrix containing all cuts, each column is one set of x
%           init_lp_model: initial LP model

n = port.n;

if ~exist('options', 'var') || isempty(options)
    options = struct;
end

if ~isfield(options, 'tol')
    options.tol = 1e-3;
end

if ~isfield(options, 'asympt_cons')
    options.asympt_cons = true;
end

if ~isfield(options, 'drop_thres')
    options.drop_thres = inf;
end

if ~isfield(options, 'drop_iter')
    options.drop_iter = inf;
end

if ~isfield(options, 'init_rprice_lb')
    options.init_rprice_lb = -100;
end

if ~isfield(options, 'x_ub')
    options.x_ub = 100 * ones(n, 1);
end

if ~isfield(options, 'switch_to_simplex')
    options.switch_to_simplex = false;
end

if ~isfield(options, 'display')
    options.display = true;
end

% whether bid-ask spread is considered
has_spread = length(price_bounds) > port.m;

output = struct;

% generate initial constraints to make the difference bounded
if ~isfield(options, 'init_lp_model')
    coef_num = length(price_bounds);
    
    if ~isempty(portlim)
        [cons_C, cons_D] = portlimcons(portlim);
        [newcons_C, newb] = replportcons(cons_C, repl, weight_fixed, ...
            has_spread);
        init_cons_num = size(newcons_C, 1);
        aux_num = size(cons_D, 2);
        lp_model = struct;
        lp_model.A = [[newcons_C, -cons_D]; ...
            [price_bounds; zeros(aux_num, 1)]'];
        lp_model.rhs = [ones(init_cons_num, 1) * 0 - newb; ...
            options.init_rprice_lb];
        init_cons_num = init_cons_num + 1;
        lp_model.sense = '>';
        l_aux = zeros(aux_num, 1);
    else
        init_cons_num = 0;
        aux_num = 0;
        lp_model = struct;
        lp_model.A = sparse(price_bounds');
        lp_model.rhs = options.init_rprice_lb;
        init_cons_num = init_cons_num + 1;
        lp_model.sense = '>';
        l_aux = zeros(0, 1);
    end
    
    if has_spread
        lp_model.lb = [zeros(coef_num, 1); l_aux];
        lp_model.lb(1) = -inf;
    else
        lp_model.lb = [-inf(coef_num, 1); l_aux];
    end
    
    lp_model.obj = [price_bounds; zeros(aux_num, 1)];
else
    lp_model = options.init_lp_model;
    lp_model.rhs(end) = options.init_rprice_lb;
    init_cons_num = size(lp_model.A, 1);
    coef_num = length(price_bounds);
    aux_num = size(lp_model.A, 2) - coef_num;
end
output.init_lp_model = lp_model;

lp_params = struct;
lp_params.FeasibilityTol = 1e-6;
lp_params.OptimalityTol = 1e-5;

% start with barrier method, later may switch to dual simplex method
lp_params.Method = 2;
lp_params.Crossover = 0;
lp_params.BarHomogeneous = 1;

if options.display
    lp_params.OutputFlag = 1;
else
    lp_params.OutputFlag = 0;
end

% aggregate all cuts
x_agg = zeros(n, 0);

% if the initial cuts are specified
if isfield(options, 'init_x')
    cons_C_x = portpointcons(port, options.init_x);
    [newcons_C_x, newb_x] = replportcons(cons_C_x, repl, weight_fixed, ...
        has_spread);
    lp_model.A = [lp_model.A; newcons_C_x, ...
        sparse(size(options.init_x, 2), aux_num)];
    lp_model.rhs = [lp_model.rhs; -newb_x];
    x_agg = options.init_x;
end

lp_init_params = lp_params;
lp_init_params.Method = 1;
lp_output = gurobi(lp_model, lp_init_params);

if ~strcmp(lp_output.status, 'OPTIMAL')
    warning('error in the initial LP, status = %s', lp_output.status);
    
    % try again with better numeric focus
    lp_params_num = lp_init_params;
    lp_params_num.NumericFocus = 3;
    lp_output = gurobi(lp_model, lp_params_num);
end

if ~strcmp(lp_output.status, 'OPTIMAL')
    warning('error in the initial LP (2nd trial), status = %s', ...
        lp_output.status);
    
    % try again with barrier and crossover
    lp_params_num = lp_init_params;
    lp_params_num.NumericFocus = 3;
    lp_params_num.Method = 2;
    lp_params_num.Crossover = -1;
    lp_output = gurobi(lp_model, lp_params_num);
end

if ~strcmp(lp_output.status, 'OPTIMAL')
    error('unexpected error in the initial LP, status = %s', ...
        lp_output.status);
end

rprice_lb = lp_output.objval;
w = lp_output.x(1:coef_num);
weight_vec = weightcollapse(w, repl, weight_fixed, has_spread);

if isfield(lp_output, 'cbasis') && isfield(lp_output, 'vbasis')
    lp_model.cbasis = lp_output.cbasis;
    lp_model.vbasis = lp_output.vbasis;
end

% iteratively introduce new constraints until the violation is below the
% tolerance
rprice = inf;
iter = 0;
lp_count = 1;
milp_count = 0;

while true
    param = port2cpwl(port, weight_vec);
    [cparam, A, b] = cpwl2concmin(param);
    
    [model, params] = concmin2gurobi(cparam, A, b, options.x_ub, true);
    
    if options.display
        params.OutputFlag = 1;
    else
        params.OutputFlag = 0;
    end
    
    g_output = gurobi(model, params);
    milp_count = milp_count + 1;
    LB = g_output.objval;
    rprice = rprice_lb - min(0, LB);
    
    if rprice - rprice_lb <= options.tol
        % gap below the tolerance
        break;
    end
    
    if isfield(g_output, 'pool')
        x_feas = horzcat(g_output.pool.xn);
        x_feas = x_feas(1:n, [g_output.pool.objval] < 0);
    else
        x_feas = g_output.x(1:n);
    end
    x_agg = [x_agg, x_feas]; %#ok<AGROW>
    
    if LB >= 0
        rprice = rprice_lb;
        break;
    end
    
    cons_C_x = portpointcons(port, x_feas);
    [newcons_C_x, newb_x] = replportcons(cons_C_x, repl, weight_fixed, ...
        has_spread);
    lp_model.A = [lp_model.A; newcons_C_x, ...
        sparse(size(x_feas, 2), aux_num)];
    lp_model.rhs = [lp_model.rhs; -newb_x];
    
    if isfield(lp_model, 'cbasis')
        lp_model.cbasis = [lp_model.cbasis; zeros(size(x_feas, 2), 1)];
    end
    
    if mod(iter, options.drop_iter) == 0
        % drop possibly redundant constraints
        cut_filter_list = cpwleval(x_agg, param)' <= options.drop_thres;
        filter_list = [true(init_cons_num, 1); cut_filter_list];
        x_agg = x_agg(:, cut_filter_list);
        lp_model.A = lp_model.A(filter_list, :);
        lp_model.rhs = lp_model.rhs(filter_list);
        
        if isfield(lp_model, 'cbasis')
            lp_model.cbasis = lp_model.cbasis(filter_list);
        end
    end
    
    if rprice_lb - options.init_rprice_lb > options.tol ...
            && options.switch_to_simplex
        % if the current lower bound is above the initial one, switch the
        % algorithm in the LP solver to the dual simplex method
        lp_params.Method = 1;
    end
    
    lp_output = gurobi(lp_model, lp_params);
    
    if ~strcmp(lp_output.status, 'OPTIMAL')
        warning('error in the LP, status = %s', lp_output.status);
        
        % try again with better numeric focus
        lp_params_num = lp_params;
        lp_params_num.NumericFocus = 3;
        lp_output = gurobi(lp_model, lp_params_num);
    end

    if ~strcmp(lp_output.status, 'OPTIMAL')
        warning('error in the LP (2nd trial), status = %s', ...
            lp_output.status);

        % switch to dual simplex and try again
        lp_params_num = lp_params;
        lp_params_num.NumericFocus = 3;
        lp_params_num.Method = 1;
        lp_output = gurobi(lp_model, lp_params_num);
    end

    if ~strcmp(lp_output.status, 'OPTIMAL')
        warning('error in the LP (3nd trial), status = %s', ...
            lp_output.status);

        % switch back to barrier with crossover and try again
        lp_params_num = lp_params;
        lp_params_num.NumericFocus = 3;
        lp_params_num.Method = 2;
        lp_params_num.Crossover = -1;
        lp_output = gurobi(lp_model, lp_params_num);
    end

    if ~strcmp(lp_output.status, 'OPTIMAL')
        error('unexpected error in the LP, status = %s', ...
            lp_output.status);
    end
    
    lp_count = lp_count + 1;
    
    rprice_lb = lp_output.objval;
    w = lp_output.x(1:coef_num);
    
    weight_vec = weightcollapse(w, repl, weight_fixed, has_spread);
    
    if isfield(lp_output, 'cbasis') && isfield(lp_output, 'vbasis')
        lp_model.cbasis = lp_output.cbasis;
        lp_model.vbasis = lp_output.vbasis;
    end
    
    iter = iter + 1;

    fprintf('iter = %4d, LB = %10.6f\n', iter, rprice_lb);
end

% prepare output
output.iter = iter;
output.lp_count = lp_count;
output.milp_count = milp_count;
x_agg(x_agg < 0) = 0;
x_agg = round(x_agg, 4);
output.x = x_agg;
output.measure = lp_output.pi(2:end);

end

