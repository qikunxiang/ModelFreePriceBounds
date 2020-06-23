rng(1000);

conf = struct;
conf.n = 60;

conf.call = cell(conf.n, 1);
conf.call(:) = {(0.5:0.5:1.5)'};

conf.cbask = struct;
conf.cbask.W = zeros(50, conf.n);
conf.cbask.W(1, :) = ones(1, conf.n) / conf.n;
conf.cbask.W(2:end, 1) = 1;
conf.cbask.W(2:end, 2:50) = -eye(50 - 1);
conf.cbask.k = cell(50, 1);
conf.cbask.k{1} = (0.5:0.5:1.5)';
conf.cbask.k(2:end) = {(-1:1:1)'};

conf.cmin = struct;
conf.cmin.L = [ones(1, conf.n); ...
    [zeros(1, 10), ones(1, 40), zeros(1, conf.n - 50)]; ...
    [ones(1, 50), zeros(1, conf.n - 50)]];
conf.cmin.k(1:2) = {(0:0.2:0.8)'};
conf.cmin.k{3} = (0:0.1:1)';

%   1: cash (1)
%   2-61: stocks (60)
%   62-241: vanilla options (3 * 60)
%   242-244: basket options (3 * 1)
%   245-391: spread options (3 * 49)
%   392-401: call-on-min (5 * 2)
%   402-412: call-on-min that is priced (11)


% marginal
marg = cell(2, 1);
marg{1} = struct;
marg{1}.mu = -0.1 * ones(conf.n, 1) + (rand(conf.n, 1) * 2 - 1) * 0.2;
marg{1}.sig2 = 0.5 * ones(conf.n, 1) + (rand(conf.n, 1) * 2 - 1) * 0.3;

marg{2}.mu = marg{1}.mu;
marg{2}.sig2 = marg{1}.sig2 + rand(conf.n, 1) * 0.1;

% dependence
A = randi([1, 10], conf.n, 3) / 10; 
dd = [3, 2, 1];

dep = cell(2, 1);
B = A * diag(dd) * A' + eye(conf.n) * 1;
dB = sqrt(diag(B));
dep{1} = struct;
dep{1}.rho = B ./ dB ./ dB';
dep{1}.rho(1:(conf.n + 1):end) = 1;
dep{1}.nu = 3;
dep{2} = struct;
B = B - eye(conf.n) * 0.3;
dB = sqrt(diag(B));
dep{2}.rho = B ./ dB ./ dB';
dep{2}.rho(1:(conf.n + 1):end) = 1;
dep{2}.nu = 20;


price_bounds = simoptprice(conf, 1e6, marg, dep);
price_bounds = roundprice(price_bounds, 3);
ill_list = price_bounds(:, 1) == 0;
price_bounds(ill_list, 1) = 1e-3;

save('exp/exp3/exp3.mat', 'conf', 'price_bounds', 'marg', 'dep');