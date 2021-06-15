load('exp/exp4/DIA_sanitized.mat');

% the number of strikes to be selected for each stock
selected_strike_num_list = round(cellfun(@(l)(length(l.strike)), ...
    option_prices) * 0.25);

% the list of strikes for each stock selected by proximity
prox_strike_list = cell(30, 1);

for i = 1:30
    [dist_sorted, dist_index] = sort(min(abs(option_prices{i}.strike ...
        - stock_prices(i) * 1.25), abs(option_prices{i}.strike ...
        - stock_prices(i) * 1.05)), 'ascend');
    prox_strike_list{i} = sort(dist_index( ...
        1:selected_strike_num_list(i)), 'ascend');
end

setting_names = {'V(25prox)', 'V(25prox)+B'};

for setid = 1:2
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
        list_i = prox_strike_list{i};
        
        conf.call{i} = option_prices{i}.strike(list_i);
        conf.put{i} = option_prices{i}.strike(list_i);
        call_prices{i} = [option_prices{i}.call_ask(list_i), ...
            option_prices{i}.call_bid(list_i)];
        put_prices{i} = [option_prices{i}.put_ask(list_i), ...
            option_prices{i}.put_bid(list_i)];

        if i == 1
            index_range.call(i, :) = 1 + [1, length(list_i)];
        else
            index_range.call(i, :) = index_range.call(i - 1, 2) ...
                + [1, length(list_i)];
        end
    end
    index_range.put = index_range.call - 1 + index_range.call(end, 2);
    
    if setid == 2
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