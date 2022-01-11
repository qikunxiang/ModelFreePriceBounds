load('exp/exp4/DIA_sanitized.mat');

rng(5000);

strike_num_list = cellfun(@(l)(length(l.strike)), ...
    option_prices);

% the number of strikes to be selected for each stock
selected_strike_num_list = cell(5, 1);
for setid = 1:4
    selected_strike_num_list{setid} = round(strike_num_list ...
        * 0.25 * setid);
end
selected_strike_num_list{5} = selected_strike_num_list{4};

rand_order = cell(30, 1);
for i = 1:30
    rand_order{i} = randsample(1:strike_num_list(i), strike_num_list(i));
end

setting_names = {'V(25)', 'V(50)', 'V(75)', 'V(100)', 'V(100)+B'};

conf = struct;
conf.n = 30;

conf.forward = false(conf.n, 1);

index_range = struct;

conf.call = cell(conf.n, 1);
conf.put = cell(conf.n, 1);
call_prices = cell(conf.n, 1);
put_prices = cell(conf.n, 1);
index_range.call = zeros(conf.n, 2);
for i = 1:conf.n
    conf.call{i} = option_prices{i}.strike;
    conf.put{i} = option_prices{i}.strike;
    call_prices{i} = [option_prices{i}.call_ask, ...
        option_prices{i}.call_bid];
    put_prices{i} = [option_prices{i}.put_ask, ...
        option_prices{i}.put_bid];

    if i == 1
        index_range.call(i, :) = 1 + [1, strike_num_list(i)];
    else
        index_range.call(i, :) = index_range.call(i - 1, 2) ...
            + [1, strike_num_list(i)];
    end
end
index_range.put = index_range.call - 1 + index_range.call(end, 2);

DIA_subset_weights = DIA_weights .* (market_cap_rank >= 6);
DIA_subset_price = DIA_subset_weights' * stock_prices;

% compute for all integer strikes between 80% and 120% of the spot price
DIA_subset_strike_lb = floor(DIA_subset_price * 0.8 / 5) * 5;
DIA_subset_strike_ub = ceil(DIA_subset_price * 1.2 / 5) * 5;
DIA_subset_strikes = (DIA_subset_strike_lb:1:DIA_subset_strike_ub)';

conf.cbask = struct;
conf.cbask.W = [DIA_weights'; DIA_subset_weights'];
conf.cbask.k = {DIA_option_prices.strike; DIA_subset_strikes};
index_range.cbask = index_range.put(end, 2) ...
    + [1, length(conf.cbask.k{1})];

index_range.repl = index_range.cbask(end, 2) ...
    + [1, length(DIA_subset_strikes)];

conf.pbask = struct;
conf.pbask.W = DIA_weights';
conf.pbask.k = {DIA_option_prices.strike};
index_range.pbask = index_range.repl(2) ...
    + [1, length(conf.pbask.k{1})];

cbask_prices = [DIA_option_prices.call_ask, ...
    DIA_option_prices.call_bid];
pbask_prices = [DIA_option_prices.put_ask, ...
    DIA_option_prices.put_bid];

price_bounds = [1, 1; vertcat(call_prices{:}); ...
    vertcat(put_prices{:}); cbask_prices; ...
    zeros(length(DIA_subset_strikes), 2); pbask_prices];

total_port_length = size(price_bounds, 1);
subset_inc_cell = cell(5, 1);
for set_id = 1:5
    subset_list = false(total_port_length, 1);
    subset_list(1) = true;

    for i = 1:conf.n
        subset_list(index_range.call(i, 1) - 1 ...
            + rand_order{i}(1:selected_strike_num_list{set_id}(i))) = true;
        subset_list(index_range.put(i, 1) - 1 ...
            + rand_order{i}(1:selected_strike_num_list{set_id}(i))) = true;
    end

    if set_id == 5
        subset_list(index_range.cbask(1):index_range.cbask(2)) = true;
        subset_list(index_range.pbask(1):index_range.pbask(2)) = true;
    end

    subset_inc_cell{set_id} = subset_list;
end

save('exp/exp4/exp_DIA1.mat', ...
    'conf', 'price_bounds', 'index_range', 'DIA_subset_weights', ...
    'DIA_subset_strikes', 'setting_names', 'subset_inc_cell');