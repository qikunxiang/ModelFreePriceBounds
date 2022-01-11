load('exp/exp4/DIA_sanitized.mat');

% check the options written on DIA

conf = struct;
conf.n = 1;

conf.forward = false(conf.n, 1);

conf.call = {DIA_option_prices.strike};
conf.put = {DIA_option_prices.strike};
call_prices = [DIA_option_prices.call_ask, ...
    DIA_option_prices.call_bid];
put_prices = [DIA_option_prices.put_ask, ...
    DIA_option_prices.put_bid];

price_bounds = [1, 1; call_prices; put_prices];

save('exp/exp4/sanitize/after_sanitize_DIA.mat', 'conf', 'price_bounds');

% check the stock options

for i = 1:30
    conf = struct;
    conf.n = 1;
    
    conf.forward = false(conf.n, 1);
    
    conf.call = {option_prices{i}.strike};
    conf.put = {option_prices{i}.strike};
    call_prices = [option_prices{i}.call_ask, ...
        option_prices{i}.call_bid];
    put_prices = [option_prices{i}.put_ask, ...
        option_prices{i}.put_bid];
    
    price_bounds = [1, 1; call_prices; put_prices];
    
    save(['exp/exp4/sanitize/after_sanitize_', tickers{i}, '.mat'], ...
        'conf', 'price_bounds');
end