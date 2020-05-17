function nprice = nonreplprice(price_bounds, repl)
% Extract the simulated price bounds on the traded derivatives
% Inputs: 
%       price_bounds: price bounds generated by function simoptprice
%       repl: logical vector specifying the portfolio to be
%           super-replicated
% Output: 
%       nprice: price bounds corresponding to traded derivatives

assert(~repl(1), 'the portfolio must not include cash');
prices = price_bounds(~repl, :);

if size(prices, 2) > 1
    nprice = [prices(:, 1); -prices(2:end, 2)];
else
    nprice = prices;
end

end

