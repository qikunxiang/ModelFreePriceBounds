% Script to compare the output two algorithms and to count the total number
% of LP problems and MILP problems solved in Experiment 3

ecp_lp = 0;
ecp_milp = 0;
accp_lp = 0;
accp_milp = 0;

d1 = load('exp/exp3a/rst/ecp.mat');
d2 = load('exp/exp3a/rst/accp.mat');
max(max(abs(d1.out_bounds - d2.out_bounds)))

for id = 1:11
    for lu = 1:2
        ecp_lp = ecp_lp + d1.outputs{id, lu}.lp_count;
        ecp_milp = ecp_milp + d1.outputs{id, lu}.milp_count;
    end
end
accp_lp = accp_lp + sum(sum(d2.lp_counts));
accp_milp = accp_milp + sum(sum(d2.milp_counts));

ecp_lp
ecp_milp
accp_lp
accp_milp