function param = port2cpwl(port, weight)
% Converting a portfolio of stocks and options to a continuous piecewise
% linear function
% Inputs:
%       port: see portcreate.m
%       weight: column vector indicating weights
% Output:
%       param: parametrization of a continuous piecewise linear function

param = struct;
param.n = port.n;

% affine part
param.aff = struct;
param.aff.a = port.aff.C * weight;
param.aff.b = port.aff.c * weight;

% half-plane part
if isfield(port, 'hp')
    hp_w = port.hp.C * weight;
    hp_abs_w = abs(hp_w);
    hp_zeros = hp_abs_w < 1e-9;
    if ~all(hp_zeros)
        param.hp = struct;
        param.hp.A = port.hp.A(~hp_zeros, :) .* hp_abs_w(~hp_zeros);
        param.hp.b = port.hp.b(~hp_zeros) .* hp_abs_w(~hp_zeros);
        param.hp.s = sign(hp_w(~hp_zeros));
    end
end

% general part
if isfield(port, 'gen')
    gen_w = port.gen.C * weight;
    gen_abs_w = abs(gen_w);
    gen_zeros = gen_abs_w < 1e-9;

    if ~all(gen_zeros)
        grp_sizes = accumarray(port.gen.grp, ...
            ones(length(port.gen.grp), 1), [], @sum);
        indi_nonzeros = repelem(~gen_zeros, grp_sizes, 1);
        grp_nonzeros_sizes = grp_sizes(~gen_zeros);
        gen_abs_w_indi = repelem(gen_abs_w(~gen_zeros), ...
            grp_nonzeros_sizes, 1);
        param.gen = struct;
        param.gen.A = port.gen.A(indi_nonzeros, :) .* gen_abs_w_indi;
        param.gen.b = port.gen.b(indi_nonzeros) .* gen_abs_w_indi;
        [~, ~, param.gen.grp] = unique(port.gen.grp(indi_nonzeros));
        param.gen.s = sign(gen_w(~gen_zeros));
        param.gen.index = port.gen.index(indi_nonzeros);
    end
end

end