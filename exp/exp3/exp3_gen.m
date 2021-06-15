rng(1000);

conf = struct;
conf.n = 5;

conf.call = cell(conf.n, 1);
conf.call(:) = {(1:10)'};

conf.cmin = struct;
conf.cmin.L = [1, 1, 1, 1, 1];
conf.cmin.k = {1};

conf.pmin = struct;
conf.pmin.L = [1, 1, 1, 1, 1];
conf.pmin.k = {4};

%   1: cash (1)
%   2-6: stocks (5)
%   7-56: vanilla options (10 * 5)
%   57: call-on-min
%   58: put-on-min


% marginal
marg = cell(2, 1);
marg{1} = struct;
marg{1}.mu = [0.5; 1; 1; 0.5; 0.5];
marg{1}.sig2 = [0.2; 0.4; 0.2; 0.4; 0.2];
marg{2} = struct;
marg{2}.mu = [0.5; 1; 1; 0.5; 0.5];
marg{2}.sig2 = [0.21; 0.42; 0.21; 0.42; 0.21];

% dependence
A = [0.8, 0.2; ...
    0.5, 0.5; ...
    0.7, -0.3; ...
    0.2, 0.8; ...
    -0.4, 0.6];

dep = cell(2, 1);
B = A * diag([2, 1]) * A' + eye(5) * 1;
dB = sqrt(diag(B));
dep{1} = struct;
dep{1}.rho = B ./ dB ./ dB';
dep{1}.rho(1:(5 + 1):end) = 1;
dep{1}.nu = 3;
dep{2} = struct;
dep{2}.rho = dep{1}.rho;
dep{2}.nu = 4;


price_bounds = simoptprice(conf, 1e6, marg, dep);
price_bounds = roundprice(price_bounds, 3);

save('exp/exp3/exp3.mat', 'conf', 'price_bounds', 'marg', 'dep');