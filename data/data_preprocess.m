% Read the first sheet containing the tickers of the stocks, their market
% capitalization based ranking, and their spot prices
TWeights = readtable('data/Data_clean_bid_ask_only.xlsx', ...
    'Sheet', 'weights', 'ReadVariableNames', true);

tickers = TWeights.Ticker(1:30);
divisor = TWeights.Divisor(1);
stock_prices = TWeights.Price(1:30);
market_cap_rank = TWeights.MarketCapRank(1:30);

% the weight vector of the DIA ETF
DIA_weights = ones(30, 1) / divisor;

% read the sheet containing prices of call options written on DIA and store
% the strikes, bid prices, and ask prices into a struct
DIA_option_prices = struct;
TCalls = readtable('data/Data_clean_bid_ask_only.xlsx', ...
    'Sheet', 'DIA_C', 'ReadVariableNames', true);
DIA_option_prices.strike = TCalls.STRIKE;
DIA_option_prices.call_bid = TCalls.BID;
DIA_option_prices.call_ask = TCalls.ASK;

% read the sheet containing prices of put options written on DIA and store
% the strikes, bid prices, and ask prices into a struct
TPuts = readtable('data/Data_clean_bid_ask_only.xlsx', ...
    'Sheet', 'DIA_P', 'ReadVariableNames', true);
DIA_option_prices.put_bid = TPuts.BID;
DIA_option_prices.put_ask = TPuts.ASK;

% iteratively read sheets
option_prices = cell(30, 1);
max_strikes = zeros(30, 1);

for i = 1:30
    option_prices{i} = struct;

    % read the sheet containing the prices of call options written on a
    % stock and store the strikes, bid prices, and ask prices
    TCalls = readtable('data/Data_clean_bid_ask_only.xlsx', ...
        'Sheet', [tickers{i}, '_C'], 'ReadVariableNames', true);
    option_prices{i}.strike = TCalls.STRIKE;
    max_strikes(i) = max(TCalls.STRIKE);
    option_prices{i}.call_bid = TCalls.BID;
    option_prices{i}.call_ask = TCalls.ASK;
    
    % read the sheet containing the prices of put options written on a
    % stock and store the strikes, bid prices, and ask prices
    TPuts = readtable('data/Data_clean_bid_ask_only.xlsx', ...
        'Sheet', [tickers{i}, '_P'], 'ReadVariableNames', true);
    option_prices{i}.put_bid = TPuts.BID;
    option_prices{i}.put_ask = TPuts.ASK;
end

% save all relevant data read from the spreadsheet into a .mat file
save('exp/exp4/DIA.mat', 'tickers', 'stock_prices', 'market_cap_rank', ...
    'DIA_weights', 'DIA_option_prices', 'option_prices', 'max_strikes');