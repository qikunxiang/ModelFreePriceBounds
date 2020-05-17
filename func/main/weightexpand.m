function weight = weightexpand(w, repl)
% Expand weights with different signs into a vector containing the positive
% and negative parts, except for the first component which represents cash,
% the positions indicated by repl specify the portfolio to be
% super-replicated
% Inputs:
%       w: the weight vector corresponding to all derivatives
%       repl: logical vector specifying the portfolio to be
%           super-replicated
% Output: 
%       weight: the expanded weight vector

assert(~repl(1), 'the portfolio must not include cash');
w = w(~repl);
weight = [w(1); max(w(2:end), 0); max(-w(2:end), 0)];

end

