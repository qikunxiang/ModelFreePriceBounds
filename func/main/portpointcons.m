function cons_C = portpointcons(port, x)
% Generate constraints on weights of the portfolio based on a set of
% specific points where the portfolio must be non-negative
% Inputs:
%       port: the portfolio structure
%       x: a matrix where each column represents a point
% Outputs:
%       cons_C: inequality constraints C * w <= 0

% preprocess x to remove very small entries to improve the numerical
% condition subsequent LP problems
x(x < 0) = 0;
x = round(x, 4); 

cons_C = x' * port.aff.C + port.aff.c;

if isfield(port, 'hp')
    hp_X = max(port.hp.A * x + port.hp.b, 0);
    cons_C = cons_C + hp_X' * port.hp.C;
end

if isfield(port, 'gen')
    if size(x, 2) == 1
        gen_X = accumarray(port.gen.grp, ...
            port.gen.A * x + port.gen.b, [], @max);
    else
        m = size(x, 2);
        V = port.gen.A * x + port.gen.b;
        s = port.gen.grp;
        S = repmat(s, 1, m) + max(s) * (0:m - 1);
        gen_X = reshape(accumarray(S(:), V(:), [], ...
            @max), max(s), m);
    end
    
    cons_C = cons_C + gen_X' * port.gen.C;
end

% round off very small entries in the coefficients to improve the numerical
% condition of subsequent LP problems
cons_C = sparse(round(cons_C, 4));

end