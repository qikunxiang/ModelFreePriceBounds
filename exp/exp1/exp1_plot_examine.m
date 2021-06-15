load('exp/exp1/exp1.mat');

xx = (0:50) / 5;
dat_V = load('exp/exp1/rst/accp_V.mat');
dat_VB = load('exp/exp1/rst/accp_V+B.mat');
dat_VBS = load('exp/exp1/rst/accp_V+B+S.mat');
dat_VBSR = load('exp/exp1/rst/accp_V+B+S+R.mat');
dat_VR = load('exp/exp1/rst/accp_V+R.mat');

sl = price_bounds(441:491, 2);
su = price_bounds(441:491, 1);
rl_V = dat_V.out_bounds(:, 2);
ru_V = dat_V.out_bounds(:, 1);
rl_VB = dat_VB.out_bounds(:, 2);
ru_VB = dat_VB.out_bounds(:, 1);
rl_VBS = dat_VBS.out_bounds(:, 2);
ru_VBS = dat_VBS.out_bounds(:, 1);
rl_VBSR = dat_VBSR.out_bounds(:, 2);
ru_VBSR = dat_VBSR.out_bounds(:, 1);
rl_VR = dat_VR.out_bounds(:, 2);
ru_VR = dat_VR.out_bounds(:, 1);

perc_rl_V = (sl - rl_V) ./ sl;
perc_ru_V = (ru_V - su) ./ su;
perc_rl_VB = (sl - rl_VB) ./ sl;
perc_ru_VB = (ru_VB - su) ./ su;
perc_rl_VBS = (sl - rl_VBS) ./ sl;
perc_ru_VBS = (ru_VBS - su) ./ su;
perc_rl_VBSR = (sl - rl_VBSR) ./ sl;
perc_ru_VBSR = (ru_VBSR - su) ./ su;
