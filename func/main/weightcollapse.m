function w = weightcollapse(weight, repl, weight_fixed, spread)
% Collapse weights from positive and negative parts back to a vector of
% weights with different signs, with fixed weights from the portfolio to be
% super-replicated added back to the designated positions
% Inputs: 
%       weight: the weight vector consisting of positive and negative parts
%           of the derivatives that are used for super-replication
%       repl: logical vector specifying the portfolio to be
%           super-replicated
%       weight_fixed: fixed weights from the portfolio to be
%           super-replicated
%       spread: boolean indicating whether bid-ask spread is present
% Output: 
%       w: the collapsed weight vector containing weights of all
%           derivatives

if ~exist('spread', 'var') || isempty(spread)
    spread = true;
end

assert(~repl(1), 'the portfolio must not include cash');
if spread
    m = (length(weight) + 1) / 2;
    w_dyn = [weight(1); weight(2:m) - weight(m + 1:end)];
else
    w_dyn = weight;
end
w = zeros(length(repl), 1);
w(repl) = -weight_fixed;
w(~repl) = w_dyn;

end

