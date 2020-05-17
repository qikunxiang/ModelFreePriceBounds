function v = lognormoptprice(mu, sig2, k, type)
% Partial expectation of log-normal distribution, used in Black-Scholes
% model
% Inputs:
%       mu: mu parameter
%       sig2: sigma^2 parameter
%       K: threshold
%       type: type of option, call (default) or put
% Output: 
%       v: value of the partial expectation

v = exp(mu + 0.5 * sig2) .* normcdf((mu + sig2 - log(k)) ./ sqrt(sig2)) ...
    - k .* normcdf(-(log(k) - mu) ./ sqrt(sig2));

if exist('type', 'var') && strcmp(type, 'put') 
    v = v - exp(mu + 0.5 * sig2) + k;
end

end

