function rounded_bounds = roundprice(price_bounds, n)
% Round the price bounds to the first n digits right of the decimal point.
% Upper bound will be rounded up, lower bound will be rounded down
% Inputs: 
%       price_bounds: the upper and lower bounds before rounding
%       n: the precision
% Output: 
%       rounded_bounds: the upper and lower bounds after rounding
base = 10 ^ n;
rounded_bounds(:, 1) = ceil(price_bounds(:, 1) * base) / base;
rounded_bounds(:, 2) = floor(price_bounds(:, 2) * base) / base;

end

