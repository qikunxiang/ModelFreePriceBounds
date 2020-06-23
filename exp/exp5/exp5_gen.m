load('exp/exp2/exp2.mat');

rst = load('exp/exp2/rst/accp_set1.mat', 'out_bounds');

sid = 6;
margin = 0.01;

price_bounds(440 + sid, 1) = rst.out_bounds(sid, 2) - margin;
price_bounds(440 + sid, 2) = 0;

save('exp/exp5/exp5_1.mat', 'conf', 'price_bounds', 'marg', 'dep');

price_bounds(440 + sid, 2) = rst.out_bounds(sid, 1) + margin;
price_bounds(440 + sid, 1) = 10;

save('exp/exp5/exp5_2.mat', 'conf', 'price_bounds', 'marg', 'dep');