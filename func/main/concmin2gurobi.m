function [model, params] = concmin2gurobi(cparam, A, b, ...
    x_ub, add_ub)
% Generate a representation of continuous piecewise linear concave
% minimization problem by a mixed-integer linear program subsequently
% passed to Gurobi
% Inputs:
%       cparam: the parameters of the concave CPWL function
%       A, b: the polyhedral feasible set A * x <= b, x >= 0 is assumed
%       x_ub: the upper bound on each component of x used for generating
%           large constants used in the MILP formulation, default = 100,
%           not enforced unless add_ub is set to true
%       add_ub: boolean indicating if x <= x_ub needs to be enforced as
%           constraints, default = false
% Outputs:
%       model: structure containing the relevant inputs to Gurobi

% the input to MILP:
%  --x-- -x_aux- --------hp-------- ----------------gen-----------------
% [  x  , x_aux ,z1, s1, y1, s2, y2,z1, s1_1, y1_1, z_2, s1_2, y1_2, ...]
% where z represents the vector part and y represents the integer part

model = struct;

% number of variables in x
n = cparam.n;
% number of variables including the auxiliary variables
n_with_aux = size(A, 2);

% a large number as heuristic upper bound of x
if ~exist('x_ub', 'var') || isempty(x_ub)
    x_ub = 100;
end

% indicator of whether to enforce this upper bound
if ~exist('add_ub', 'var') || isempty(add_ub)
    add_ub = false;
end

% position of current last component in the input vector, the half-plane
% part and the general part will be added
cur_offset = n_with_aux;

hp_count = 0;
if isfield(cparam, 'hp')
    % number of half-planes
    hp_count = size(cparam.hp.A, 1);
    % A and b from the half-plane part
    hp_A = cparam.hp.A;
    hp_b = cparam.hp.b;
    % index of z of each half-plane
    hp_z_index = zeros(hp_count, 1);
    % index of s of each half-plane
    hp_s_index = zeros(hp_count, 1);
    % index of y of each half-plane
    hp_y_index = zeros(hp_count, 1);
    
    for hpid = 1:hp_count
        % calculate the index of z for the current half-plane
        hp_z_index(hpid) = 1 + cur_offset;
        % calculate the index of s for the current half-plane
        hp_s_index(hpid) = 2 + cur_offset;
        % calculate the index of y for the current half-plane
        hp_y_index(hpid) = 3 + cur_offset;
        % update the current offset
        cur_offset = cur_offset + 3;
    end
end

gen_count = 0;
if isfield(cparam, 'gen')
    % number of groups
    gen_count = max(cparam.gen.grp);
    % A and b from the general part
    gen_A = cell(gen_count, 1);
    gen_b = cell(gen_count, 1);
    % size of each group
    gen_grp_sizes = zeros(gen_count, 1);
    % index of each z of each group
    gen_z_index = zeros(gen_count, 1);
    % index of each s of each group
    gen_s_index = cell(gen_count, 1);
    % index of each y of each group
    gen_y_index = cell(gen_count, 1);
    
    % iterate through each group
    for grpid = 1:gen_count
        gen_list = cparam.gen.grp == grpid;
        gen_grp_sizes(grpid) = sum(gen_list);
        gen_A{grpid} = cparam.gen.A(gen_list, :);
        gen_b{grpid} = cparam.gen.b(gen_list);
        % calculate the index of z for the current group
        gen_z_index(grpid) = 1 + cur_offset;
        % calculate the index of s for the current group
        gen_s_index{grpid} = (1:gen_grp_sizes(grpid)) * 2 + cur_offset;
        % calculate the index of y for the current group
        gen_y_index{grpid} = (1:gen_grp_sizes(grpid)) * 2 + 1 + cur_offset;
        % update the current offset
        cur_offset = cur_offset + 1 + 2 * gen_grp_sizes(grpid);
    end
end

% length of the input vector
input_len = cur_offset;

milp_c = cparam.aff.b;
milp_f = zeros(input_len, 1);
milp_f(1:n) = cparam.aff.a;
milp_f(n + 1:n_with_aux) = 1;
milp_bincon = false(input_len, 1);
milp_lb = -inf(input_len, 1);
milp_lb(1:n) = 0;
milp_ub = inf(input_len, 1);

if add_ub
    % enforce the upper bounds on x if required
    milp_ub(1:n) = x_ub;
end

% prepare the MILP outputs for the half-plane part
milp_hp_Aeq = zeros(hp_count, input_len);
milp_hp_beq = zeros(hp_count, 1);
milp_hp_A = zeros(hp_count * 2, input_len);
milp_hp_b = zeros(hp_count * 2, 1);

for hpid = 1:hp_count
    % set the binary-valued components
    milp_bincon(hp_y_index(hpid)) = true;
    
    % update the z part of the objective function
    milp_f(hp_z_index(hpid)) = -1;
    
    % equality constraint, defining slack variable
    milp_hp_Aeq(hpid, 1:n) = hp_A(hpid, :);
    milp_hp_Aeq(hpid, hp_z_index(hpid)) = -1;
    milp_hp_Aeq(hpid, hp_s_index(hpid)) = 1;
    milp_hp_beq(hpid) = -hp_b(hpid);
    
    % first inequality, characterizing z
    cur_M_u = max(1, sum(max(hp_A(hpid, :), 0)) * x_ub + hp_b(hpid));
    milp_hp_A(2 * hpid - 1, hp_z_index(hpid)) = 1;
    milp_hp_A(2 * hpid - 1, hp_y_index(hpid)) = cur_M_u;
    milp_hp_b(2 * hpid - 1) = cur_M_u;
    % second inequality, characterizing s
    cur_M_l = max(1, sum(max(-hp_A(hpid, :), 0)) * x_ub - hp_b(hpid));
    milp_hp_A(2 * hpid, hp_s_index(hpid)) = 1;
    milp_hp_A(2 * hpid, hp_y_index(hpid)) = -cur_M_l;
    milp_hp_b(2 * hpid) = 0;
    
    % set the lower bounds of z and s
    milp_lb(hp_z_index(hpid)) = 0;
    milp_lb(hp_s_index(hpid)) = 0;
end

% prepare the MILP outputs for the general part
milp_gen_Aeq1 = cell(gen_count, 1);
milp_gen_beq1 = cell(gen_count, 1);
milp_gen_Aeq2 = zeros(gen_count, input_len);
milp_gen_beq2 = ones(gen_count, 1);
milp_gen_A = cell(gen_count, 1);
milp_gen_b = cell(gen_count, 1);
for grpid = 1:gen_count
    % set the integer-valued components
    milp_bincon(gen_y_index{grpid}) = true;
    
    % update the z part of the objective function
    milp_f(gen_z_index(grpid)) = -1;
    
    cur_grp_size = gen_grp_sizes(grpid);
    
    % first set of equalities, defining slack variables
    milp_gen_Aeq1{grpid} = zeros(cur_grp_size, input_len);
    milp_gen_Aeq1{grpid}(:, 1:n) = gen_A{grpid};
    milp_gen_Aeq1{grpid}(:, gen_z_index(grpid)) = -1;
    milp_gen_Aeq1{grpid}(:, gen_s_index{grpid}) = eye(cur_grp_size);
    milp_gen_beq1{grpid} = -gen_b{grpid};
    
    % second set of equalities, forcing sum of y's to be 1
    milp_gen_Aeq2(grpid, gen_y_index{grpid}) = 1;
    
    % inequalities, characterizing y's
    cur_M = zeros(cur_grp_size, 1);
    
    for gidx = 1:cur_grp_size
        cur_M(gidx) = max(1, max(sum(max(gen_A{grpid} ...
            - gen_A{grpid}(gidx, :), 0) * x_ub, 2) ...
            + gen_b{grpid} - gen_b{grpid}(gidx)));
    end
    
    milp_gen_A{grpid} = zeros(cur_grp_size, input_len);
    milp_gen_A{grpid}(:, gen_s_index{grpid}) = eye(cur_grp_size);
    milp_gen_A{grpid}(:, gen_y_index{grpid}) = diag(cur_M);
    milp_gen_b{grpid} = cur_M;
    
    milp_lb(gen_s_index{grpid}) = 0;
end

% aggregate all inequality constraints
milp_A = [milp_hp_A; vertcat(milp_gen_A{:}); ...
    [A, zeros(size(A, 1), input_len - n_with_aux)]];
milp_b = [milp_hp_b; vertcat(milp_gen_b{:}); b];

% aggregate all equality constraints
milp_Aeq = [milp_hp_Aeq; vertcat(milp_gen_Aeq1{:}); milp_gen_Aeq2];
milp_beq = [milp_hp_beq; vertcat(milp_gen_beq1{:}); milp_gen_beq2];

% construct the return value
model.obj = milp_f;
model.objcon = milp_c;
model.A = [sparse(milp_Aeq); sparse(milp_A)];
model.rhs = [milp_beq; milp_b];
model.sense = [repmat('=', size(milp_Aeq, 1), 1); ...
    repmat('<', size(milp_A, 1), 1)];
model.lb = milp_lb;
model.ub = milp_ub;
model.vtype = repmat('C', length(milp_bincon), 1);
model.vtype(milp_bincon) = 'B';

params = struct;
params.IntFeasTol = 1e-6;
params.PoolSolutions = 100;
params.PoolGap = 0.7;
params.OutputFlag = 0;
params.NodefileStart = 2;
params.TimeLimit = 600;
params.NodeLimit = 5e5;

end