load('exp/exp4/DIA.mat');

% sanitize the prices of options written on DIA
[DIA_call_modify, DIA_put_modify] = optionpricesanitize( ...
    DIA_option_prices.strike, ...
    DIA_option_prices.call_bid, DIA_option_prices.call_ask, ...
    DIA_option_prices.put_bid, DIA_option_prices.put_ask, ...
    [0; DIA_option_prices.strike; DIA_option_prices.strike(end) * 2]);

DIA_option_prices.call_bid = DIA_option_prices.call_bid ...
    + DIA_call_modify(:, 1);
DIA_option_prices.call_ask = DIA_option_prices.call_ask ...
    + DIA_call_modify(:, 2);
DIA_option_prices.put_bid = DIA_option_prices.put_bid ...
    + DIA_put_modify(:, 1);
DIA_option_prices.put_ask = DIA_option_prices.put_ask ...
    + DIA_put_modify(:, 2);

modify = cell(30, 1);
for i = 1:30
    stock = option_prices{i};

    % prices of options written on CVX with strike prices below $50 
    % are anomalous and are removed from the experiment as outliers
    if i == 8
        % the 8-th lowest strike price is $50
        stock.strike = stock.strike(8:end);
        stock.call_bid = stock.call_bid(8:end);
        stock.call_ask = stock.call_ask(8:end);
        stock.put_bid = stock.put_bid(8:end);
        stock.put_ask = stock.put_ask(8:end);
    end
    
    % sanitize the prices of options written on a stock
    modify{i} = struct;
    [modify{i}.call, modify{i}.put] = optionpricesanitize( ...
        stock.strike, ...
        stock.call_bid, stock.call_ask, ...
        stock.put_bid, stock.put_ask, ...
        [0; stock.strike; stock.strike(end) * 2]);
    stock.call_bid = stock.call_bid + modify{i}.call(:, 1);
    stock.call_ask = stock.call_ask + modify{i}.call(:, 2);
    stock.put_bid = stock.put_bid + modify{i}.put(:, 1);
    stock.put_ask = stock.put_ask + modify{i}.put(:, 2);
    
    option_prices{i} = stock;
end

save('exp/exp4/DIA_sanitized.mat', 'tickers', 'stock_prices', ...
    'market_cap_rank', 'DIA_weights', 'DIA_option_prices', ...
    'option_prices', 'max_strikes', 'DIA_call_modify', ...
    'DIA_put_modify', 'modify');