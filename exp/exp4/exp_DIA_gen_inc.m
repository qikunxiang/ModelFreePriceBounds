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

for setid = 1:5
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
        list_i = false(strike_num_list(i), 1);
        list_i(rand_order{i}(1:selected_strike_num_list{setid}(i))) = true;
        conf.call{i} = option_prices{i}.strike(list_i);
        conf.put{i} = option_prices{i}.strike(list_i);
        call_prices{i} = [option_prices{i}.call_ask(list_i), ...
            option_prices{i}.call_bid(list_i)];
        put_prices{i} = [option_prices{i}.put_ask(list_i), ...
            option_prices{i}.put_bid(list_i)];

        if i == 1
            index_range.call(i, :) = 1 + [1, sum(list_i)];
        else
            index_range.call(i, :) = index_range.call(i - 1, 2) ...
                + [1, sum(list_i)];
        end
    end
    index_range.put = index_range.call - 1 + index_range.call(end, 2);
    
    if setid == 5
        conf.cbask = struct;
        conf.cbask.W = DIA_weights';
        conf.cbask.k = {DIA_option_prices.strike};
        index_range.cbask = index_range.put(end, 2) ...
            + [1, length(conf.cbask.k{1})];
        
        conf.pbask = struct;
        conf.pbask.W = DIA_weights';
        conf.pbask.k = {DIA_option_prices.strike};
        index_range.pbask = index_range.cbask(end, 2) ...
            + [1, length(conf.cbask.k{1})];
        
        cbask_prices = [DIA_option_prices.call_ask, ...
            DIA_option_prices.call_bid];
        pbask_prices = [DIA_option_prices.put_ask, ...
            DIA_option_prices.put_bid];
    else
        cbask_prices = zeros(0, 2);
        pbask_prices = zeros(0, 2);
    end

    conf.boc = struct;
    DIA_price = DIA_weights' * stock_prices;
    conf.boc.L = {[eye(30) ./ stock_prices; DIA_weights' ./ DIA_price] ...
        * 100};
    conf.boc.k = {[125 * ones(30, 1); 105]'};
    
    price_bounds = [1, 1; vertcat(call_prices{:}); ...
        vertcat(put_prices{:}); cbask_prices; pbask_prices];
    
    save(sprintf('exp/exp4/exp_DIA_%s.mat', setting_names{setid}), ...
        'conf', 'price_bounds', 'index_range');
end