function v = lognorm_partialexp(mu, sig2, k1, k2, a, b)
% Compute the partial expectation of a log-normal distribution of the form
% E[(aX+b)I{k1,k2}], where mu, sig2, a, b, k1, k2 are vectors of the same
% length (or constants)
% Inputs:
%       mu: the location parameter of the log-normal distribution
%       sig2: the scale parameter (sigma squared) of the log-normal
%           distribution
%       k1: the left end point of the interval (lower integration limit)
%       k2: the right end point of the interval (upper integration limit)
%       a: the coefficient of X
%       b: the intercept
% Outputs:
%       v: the value of the partial expectation

if length(k1) == 1 && length(k2) > 1
    k1 = repmat(k1, length(k2), 1);
elseif length(k2) == 1 && length(k1) > 1
    k2 = repmat(k2, length(k1), 1);
end

k2 = max(k1, k2);

% place the end points into a matrix
mat = log([k1, k2]);

% standardize the inputs
mat = (mat - mu) ./ sqrt(sig2);

mat = [mat, sqrt(sig2) - mat];
P = normcdf(mat);

v = b .* (P(:, 2) - P(:, 1)) + a .* exp(mu + 0.5 * sig2) ...
    .* (P(:, 3) - P(:, 4));

end

