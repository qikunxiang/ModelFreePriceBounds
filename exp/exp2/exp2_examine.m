ecp_lp = 0;
ecp_milp = 0;
accp_lp = 0;
accp_milp = 0;

for setting = 1:4
d1 = load(sprintf('exp/exp2/rst/ecp_set%d.mat', setting));
d2 = load(sprintf('exp/exp2/rst/accp_set%d.mat', setting));
diff = d1.out_bounds(:) - d2.out_bounds(:);
diff2 = d1.out_bounds(:) - d2.out_bounds_o(:);
max(abs(diff))
max(abs(diff2))

for id = 1:51
    for lu = 1:2
        ecp_lp = ecp_lp + d1.outputs{id, lu}.lp_count;
        ecp_milp = ecp_milp + d1.outputs{id, lu}.milp_count;
    end
end
accp_lp = accp_lp + sum(sum(d2.lp_counts));
accp_milp = accp_milp + sum(sum(d2.milp_counts));

end

ecp_lp
ecp_milp
accp_lp
accp_milp