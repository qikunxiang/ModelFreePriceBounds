setting_names = {'V+B+S', 'V+B+S+R'};

for setting = 1:2
    ecp_lp = 0;
    ecp_milp = 0;
    accp_lp = 0;
    accp_milp = 0;

    fprintf('#### Case %d ####\n', setting);

    d1 = load(sprintf('exp/exp2/rst/ecp_%s.mat', setting_names{setting}));
    d2 = load(sprintf('exp/exp2/rst/accp_%s.mat', setting_names{setting}));
    max(max(abs(d1.out_bounds - d2.out_bounds)))
    max(max(abs(d1.out_bounds - d2.out_bounds_o)))

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
end

