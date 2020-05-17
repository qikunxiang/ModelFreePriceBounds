function [newcons_C, newb] = replportcons(cons_C, repl, weight_fixed, ...
    spread)
% Process constraints in the case of super-replicating a fixed portfolio
% Inputs:
%       cons_C: full constraints matrix
%       repl: logical vector indicating the position of the portfolio to be
%           super-replicated
%       weight_fixed: the weights of the portfolio to be super-replicated
%       spread: boolean indicating whether bid-ask spread is considered
% Outputs:
%       newcons_C: updated constraints matrix including positive and
%           negative parts, with weights corresponding to the portfolio to
%           be super-replicated removed
%       newb: the intercept that needs to be subtracted from the
%           right-hand-side of the inequalities

assert(~repl(1), 'the portfolio must not include cash');

if ~exist('spread', 'var') || isempty(spread)
    spread = true;
end

repl_C = cons_C(:, repl);
nonr_C = cons_C(:, ~repl);

if spread
    newcons_C = [nonr_C, -nonr_C(:, 2:end)];
else
    newcons_C = nonr_C;
end

newb = full(-repl_C * weight_fixed);

if isempty(newb)
    newb = zeros(size(newcons_C, 1), 1);
end

end
