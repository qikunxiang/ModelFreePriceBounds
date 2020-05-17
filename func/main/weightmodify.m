function weight = weightmodify(w)
% Modify weights with possibly non-zero entries for both positive and
% negative parts
% Inputs:
%       w: the weight vector with positive and negative parts
% Output: 
%       weight: the modified weight vector with only positive or negative
%           part for each derivative

m = (length(w) + 1) / 2;
w2 = w(2:m) - w(m + 1:end);
weight = [w(1); max(w2, 0); max(-w2, 0)];

end

