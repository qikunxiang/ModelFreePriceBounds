V25 = load('exp/exp4/rst/ecp_V(25).mat', 'out_bounds');
V50 = load('exp/exp4/rst/ecp_V(50).mat', 'out_bounds');
V75 = load('exp/exp4/rst/ecp_V(75).mat', 'out_bounds');
V100 = load('exp/exp4/rst/ecp_V(100).mat', 'out_bounds');
V100B = load('exp/exp4/rst/ecp_V(100)+B.mat', 'out_bounds');

V25prox = load('exp/exp4/rst/ecp_V(25prox).mat', 'out_bounds');
V25proxB = load('exp/exp4/rst/ecp_V(25prox)+B.mat', 'out_bounds');

fprintf('%20s %20s %20s %20s %20s\n', '-- V(25%) --', '-- V(50%) --', ...
    '-- V(75%) --', '-- V(100%) --', '-- V(100%)+B --');
fprintf('%20.6f %20.6f %20.6f %20.6f %20.6f\n', V25.out_bounds(1), ...
    V50.out_bounds(1), V75.out_bounds(1), V100.out_bounds(1), ...
    V100B.out_bounds(1));
fprintf('%20.6f %20.6f %20.6f %20.6f %20.6f\n', V25.out_bounds(2), ...
    V50.out_bounds(2), V75.out_bounds(2), V100.out_bounds(2), ...
    V100B.out_bounds(2));

fprintf('%20s %20s\n', '-- V(25% prox) --', '-- V(25% prox)+B --');
fprintf('%20.6f %20.6f\n', V25prox.out_bounds(1), V25proxB.out_bounds(1));
fprintf('%20.6f %20.6f\n', V25prox.out_bounds(2), V25proxB.out_bounds(2));