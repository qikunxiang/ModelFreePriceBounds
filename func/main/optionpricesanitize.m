function [call_mod, put_mod] = optionpricesanitize(strike, ...
    call_bid, call_ask, put_bid, put_ask, support)
% Modifying bid and ask prices of options to remove arbitrage possibilities
% by decreasing bid prices and increasing ask prices
% Inputs: 
%       strike: strikes of the options
%       call_bid: bid prices of the call options
%       call_ask: ask prices of the call options
%       put_bid: bid prices of the put options
%       put_ask: ask prices of the put options
%       support: support of the probability distribution
% Output:
%       call_mod: the amount of call option prices that are modified
%       put_mod: the amount of put option prices that are modified

m = length(strike);
K = length(support);

obj = [ones(4 * m, 1); zeros(K, 1)];

call_vals = sparse(max(support' - strike, 0));
put_vals = sparse(max(strike - support', 0));

A_call_ask = [-speye(m), sparse(m, m * 3), call_vals];
b_call_ask = call_ask;
sense_call_ask = repmat('<', m, 1);

A_call_bid = [sparse(m, m), speye(m), sparse(m, m * 2), call_vals];
b_call_bid = call_bid;
sense_call_bid = repmat('>', m, 1);

A_put_ask = [sparse(m, m * 2), -speye(m), sparse(m, m), put_vals];
b_put_ask = put_ask;
sense_put_ask = repmat('<', m, 1);

A_put_bid = [sparse(m, m * 3), speye(m), put_vals];
b_put_bid = put_bid;
sense_put_bid = repmat('>', m, 1);

A_eq = sparse([zeros(1, 4 * m), ones(1, K)]);
b_eq = 1;
sense_eq = '=';

% use 1e-6 as the lower bound to make sure the probabilities are positive
lb = [zeros(4 * m, 1); 1e-6 * ones(K, 1)];
ub = inf(4 * m + K, 1);

model = struct;
model.modelsense = 'min';
model.obj = obj;
model.A = [A_call_ask; A_call_bid; A_put_ask; A_put_bid; A_eq];
model.rhs = [b_call_ask; b_call_bid; b_put_ask; b_put_bid; b_eq];
model.sense = [sense_call_ask; sense_call_bid; ...
    sense_put_ask; sense_put_bid; sense_eq];
model.lb = lb;
model.ub = ub;

params = struct;
params.OutputFlag = 0;

output = gurobi(model, params);

call_mod = [-output.x(m + 1:2 * m), output.x(1:m)];
put_mod = [-output.x(3 * m + 1:4 * m), output.x(2 * m + 1:3 * m)];

end

