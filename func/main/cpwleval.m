function f = cpwleval(x, param)
% Evaluate a continuous piecewise linear (CPWL) function
% The function is a sum over three parts:
%       param.aff:  affine part a' * x + b
%                   a is a column vector
%                   b is a scalar
%       param.hp:   half-plane s' * max(A' * x + b, 0)
%                   A is a matrix in which each row corresponds to a'
%                   b is a column vector
%                   s is a column vector of -1 and 1
%       param.gen:  general sum(s(i) * max(a1'* x + b1, a2' * x + b2, ...))
%                   A is a matrix in which each row corresponds to a'
%                   b is a column vector
%                   grp is a column vector of indices indicating to which
%                   max bracket the a and b belongs
%                   s is a column vector of -1 and 1
% If multiple input x are passed, each column of x will be taken as an
% input

f = param.aff.a' * x + param.aff.b;

if isfield(param, 'hp')
    f = f + param.hp.s' * max(param.hp.A * x + param.hp.b, 0);
end

if isfield(param, 'gen')
    m = size(x, 2);
    V = param.gen.A * x + param.gen.b;
    S = repmat(param.gen.grp, 1, m) + max(param.gen.grp) * (0:m - 1);
    V_mat = -inf(max(S(:)), max(param.gen.index));
    V_mat(sub2ind(size(V_mat), S(:), ...
        repmat(param.gen.index, m, 1))) = V(:);
    V_max = max(V_mat, [], 2);
    f = f + param.gen.s' * reshape(V_max, max(param.gen.grp), m);
end

end

