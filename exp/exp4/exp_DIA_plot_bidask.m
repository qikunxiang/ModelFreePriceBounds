load('exp/exp4/DIA.mat');

san = load('exp/exp4/DIA_sanitized.mat');

mod_count = zeros(31, 1);
mod_count(1) = sum(sum(san.DIA_call_modify ~= 0)) ...
    + sum(sum(san.DIA_put_modify ~= 0));
mod_max = max(max(max(abs(san.DIA_call_modify))), ...
    max(max(abs(san.DIA_put_modify))));

for i = 1:30
    mod_count(i + 1) = sum(sum(san.modify{i}.call ~= 0)) ...
        + sum(sum(san.modify{i}.put ~= 0));
    mod_max = max([mod_max, max(max(abs(san.modify{i}.call))), ...
        max(max(abs(san.modify{i}.put)))]);
end

figure('Position', [100, 100, 400, 300]);
[ha, pos] = tight_subplot(1, 1, [0, 0], [0.11, 0.06], [0.09, 0.03]);
hold on;

call_bid = plot(DIA_option_prices.strike, DIA_option_prices.call_bid, ...
    ':', 'Color', 'blue');
call_ask = plot(DIA_option_prices.strike, DIA_option_prices.call_ask, ...
    '-', 'Color', 'blue');
put_bid = plot(DIA_option_prices.strike, DIA_option_prices.put_bid, ...
    ':', 'Color', 'red');
put_ask = plot(DIA_option_prices.strike, DIA_option_prices.put_ask, ...
    '-', 'Color', 'red');
DIA_price = DIA_weights' * stock_prices;
price = line(DIA_price * ones(2, 1), get(gca, 'YLim'), ...
    'LineStyle', '--', 'Color', 'black');

set(gca, 'XLim', [min(DIA_option_prices.strike), ...
     max(DIA_option_prices.strike)]);

legend([call_bid, call_ask, put_bid, put_ask, price], ...
    'call - bid price', 'call - ask price', ...
    'put - bid price', 'put - ask price', 'spot price');
legend boxoff;

xlabel('strike');
ylabel('price');
title('DIA');


for id = [1, 8]
figure('Position', [100, 100, 400, 300]);
[ha, pos] = tight_subplot(1, 1, [0, 0], [0.11, 0.06], [0.09, 0.03]);
hold on;

call_bid = plot(option_prices{id}.strike, option_prices{id}.call_bid, ...
    ':', 'Color', 'blue');
call_ask = plot(option_prices{id}.strike, option_prices{id}.call_ask, ...
    '-', 'Color', 'blue');
put_bid = plot(option_prices{id}.strike, option_prices{id}.put_bid, ...
    ':', 'Color', 'red');
put_ask = plot(option_prices{id}.strike, option_prices{id}.put_ask, ...
    '-', 'Color', 'red');
price = line(stock_prices(id) * ones(2, 1), get(gca, 'YLim'), ...
    'LineStyle', '--', 'Color', 'black');

if id == 8
    anomaly = line(50 * ones(2, 1), get(gca, 'YLim'), ...
        'LineStyle', '-', 'Color', 'black', 'LineWidth', 2);
end

set(gca, 'XLim', [min(option_prices{id}.strike), ...
     max(option_prices{id}.strike)]);

legend([call_bid, call_ask, put_bid, put_ask, price], ...
    'call - bid price', 'call - ask price', ...
    'put - bid price', 'put - ask price', 'spot price');
legend boxoff;

xlabel('strike');
ylabel('price');
title(tickers{id});
end