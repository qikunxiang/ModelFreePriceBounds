function [x, r] = polytopecenterempty_gurobi(A, b, g_display)
% Get the Chebyshev center of a possibly empty polytope
% Inputs: 
%       A, b: representation of polytope {x: A * x <= b}
%       g_display: whether to display Gurobi output
% Outputs: 
%       x: the robust center, empty when the polytope is empty
%       r: the radius of the ball, empty when the polytope is empty

if ~exist('g_display', 'var') || isempty(g_display)
    g_display = false;
end

n = size(A, 2);

model = struct;
model.obj = [zeros(n, 1); 1];
model.modelsense = 'max';
model.A = [A, sqrt(sum(A .^ 2, 2))];
model.rhs = b;
model.lb = [-inf(n, 1); 0];

params = struct;
params.Method = 2;
params.FeasibilityTol = 1e-8;
params.OptimalityTol = 1e-6;
params.BarConvTol = 1e-9;
params.BarHomogeneous = 1;
params.CrossoverBasis = 1;

if g_display
    params.OutputFlag = 1;
else
    params.OutputFlag = 0;
end

output = gurobi(model, params);

if strcmp(output.status, 'NUMERIC')
    % if there is numerical issue, try with a higher numeric focus
    params_num = params;
    params_num.NumericFocus = 3;
    output = gurobi(model, params_num);
end

if strcmp(output.status, 'NUMERIC')
    % if numerical issue persists, try without crossover
    params_num = params;
    params_num.NumericFocus = 3;
    params_num.Crossover = 0;
    output = gurobi(model, params_num);
end

if ~strcmp(output.status, 'OPTIMAL')
    x = [];
    r = [];
else
    x = output.x(1:end - 1);
    r = output.objval;
end

end