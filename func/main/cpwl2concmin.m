function [cparam, A, b] = cpwl2concmin(param)
% Converting the minimization of a continuous piecewise linear function
% into a concave minimization problem
% Inputs:
%       param: the parameters of the CPWL function
% Outputs:
%       cparam: the parameters of the resulting concave CPWL function
%       A, b: the resulting polyhedral set A * x <= b, x >= 0 is assumed

cparam = struct;

% count the number of convex components
hp_pos_num = 0;

if isfield(param, 'hp')
    hp_pos_list = param.hp.s == 1;
    hp_neg_list = param.hp.s == -1;
    hp_pos_num = sum(hp_pos_list);
end

gen_pos_num = 0;
if isfield(param, 'gen')
    gen_pos_list = param.gen.s == 1;
    gen_neg_list = param.gen.s == -1;
    gen_pos_num = sum(gen_pos_list);
end

cparam.n = param.n;

% affine part
cparam.aff = struct;
cparam.aff.a = param.aff.a;
cparam.aff.b = param.aff.b;

% half-plane part
if isfield(param, 'hp')
    if sum(hp_neg_list) > 0
        cparam.hp = struct;
        cparam.hp.A = param.hp.A(hp_neg_list, :);
        cparam.hp.b = param.hp.b(hp_neg_list);
        cparam.hp.s = param.hp.s(hp_neg_list);
    end
    
    if hp_pos_num > 0
        hp_A = [repelem(param.hp.A(hp_pos_list, :), 2, 1) ...
            .* repmat([1; 0], hp_pos_num, 1), ...
            repelem(-eye(hp_pos_num), 2, 1), ...
            zeros(hp_pos_num * 2, gen_pos_num)];
        hp_b = repelem(param.hp.b(hp_pos_list), 2, 1) ...
            .* repmat([-1; 0], hp_pos_num, 1);
    else
        hp_A = zeros(0, param.n + hp_pos_num + gen_pos_num);
        hp_b = zeros(0, 1);
    end
else
    hp_A = zeros(0, param.n + hp_pos_num + gen_pos_num);
    hp_b = zeros(0, 1);
end

% general part
if isfield(param, 'gen')
    if sum(gen_neg_list) > 0
        cparam.gen = struct;
        row_neg_list = ismember(param.gen.grp, find(gen_neg_list));
        cparam.gen.A = param.gen.A(row_neg_list, :);
        cparam.gen.b = param.gen.b(row_neg_list);
        cparam.gen.s = param.gen.s(gen_neg_list);
        [~, ~, cparam.gen.grp] = unique(param.gen.grp(row_neg_list));
    end
    
    if gen_pos_num > 0
        row_pos_list = ismember(param.gen.grp, find(gen_pos_list));
        [~, ~, pos_grp] = unique(param.gen.grp(row_pos_list));
        grp_sizes = accumarray(pos_grp, ones(length(pos_grp), 1), ...
            [], @sum);
        gen_A = [param.gen.A(row_pos_list, :), ...
            zeros(sum(row_pos_list), hp_pos_num), ...
            repelem(-eye(gen_pos_num), grp_sizes, 1)];
        gen_b = -param.gen.b(row_pos_list);
    else
        gen_A = zeros(0, param.n + hp_pos_num + gen_pos_num);
        gen_b = zeros(0, 1);
    end
else
    gen_A = zeros(0, param.n + hp_pos_num + gen_pos_num);
    gen_b = zeros(0, 1);
end

A = [hp_A; gen_A];
b = [hp_b; gen_b];

end