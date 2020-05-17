function sub = portsubset(port, list)
% Taking a subset of a portfolio of stocks and options
% Input:
%       port: port object returned by function portcreate
%       list: logical list of instruments to be included in the subset
% Output:
%       sub: subset of portfolio

sub = struct;
sub.n = port.n;
sub.m = sum(list);

sub.aff.C = port.aff.C(:, list);
sub.aff.c = port.aff.c(:, list);

if isfield(port, 'hp')
    hp_C = port.hp.C(:, list);
    
    % list of half-planes that are still relevant
    hp_rel_list = ~all(hp_C == 0, 2);
    sub.hp = struct;
    sub.hp.A = port.hp.A(hp_rel_list, :);
    sub.hp.b = port.hp.b(hp_rel_list);
    sub.hp.C = hp_C(hp_rel_list, :);
end

if isfield(port, 'gen')
    gen_C = port.gen.C(:, list);
    
    % list of general forms that are still relevant
    gen_grp_rel_list = ~all(gen_C == 0, 2);
    gen_rel_list = ismember(port.gen.grp, find(gen_grp_rel_list));
    sub.gen = struct;
    sub.gen.A = port.gen.A(gen_rel_list, :);
    sub.gen.b = full(port.gen.b(gen_rel_list));
    sub.gen.C = gen_C(gen_grp_rel_list, :);
    sub.gen.index = port.gen.index(gen_rel_list);
    [~, ~, sub.gen.grp] = unique(port.gen.grp(gen_rel_list));
end

end

