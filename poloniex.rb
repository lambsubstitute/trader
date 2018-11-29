#require './httparty'
require 'httparty'
require 'json'


TIME_PERIOD = 1
MOVING_AVERAGE = 5
SHORTCIRCUIT_FLAG = false
# MOVING AVERAGE sets how long the moving average should be set for, ie the candle times
# for example, if you set the TIME PERIOD TO 30 seconds between calls, and the moving average to 1 minute, it wil take 2 calls a minute
# if oyu set th etime period to 10 seconds and the moving average to 1 minute (60 seconds) it wil take 6 calls a minute

# set run time in minutes
RUN_TIME = 60
@run_timer = RUN_TIME * (60 * TIME_PERIOD)

def create_timing_and_sample_sizes
  data_sample_length = MOVING_AVERAGE / TIME_PERIOD
  @ma_2_interval = 2 * data_sample_length
  @ma_7_interval = 7 * data_sample_length
  @ma_30_interval = 30 * data_sample_length

  puts "take a sample every " + TIME_PERIOD.to_s + " seconds"
  puts "calculating on a " + MOVING_AVERAGE.to_s + " second moving average"
  puts "this means taking " + data_sample_length.to_s + " data samples per candle"
  puts "2 candle moving average requires " + @ma_2_interval.to_s + " data samples to be taken"
  puts "7 candle moving average requires " + @ma_7_interval.to_s + " data samples to be taken"
  puts "30 candle moving average requires " + @ma_30_interval.to_s + " data samples to be taken"
end



# profit and loss accumulators to track trades in each pot
@trade_returns_pot1 = 0
@trade_returns_pot2 = 0
@trade_returns_pot3 = 0

# current buy price, unsure if needed any more
@trade1_buyprice = 0
@trade2_buyprice = 0
@trade3_buyprice = 0

# save the last buy price for comparisons when its time to sell this trade off
@trade_pot1_lastbuyprice = 0
@trade_pot2_lastbuyprice = 0
@trade_pot3_lastbuyprice = 0

# keep a count of the losing trades
@trade1_loss_counter = 0
@trade2_loss_counter = 0
@trade3_loss_counter = 0
#loss total tally
@trade1_loss_total = 0
@trade2_loss_total = 0
@trade3_loss_total = 0

# keep a count of the gaining trades
@trade1_gains_counter = 0
@trade2_gains_counter = 0
@trade3_gains_counter = 0

# keep count of short circuit breaks
@trade1_shortcircuit_counter = 0
@trade2_shortcircuit_counter = 0
@trade3_shortcircuit_counter = 0

# flag to say if trade is currently in place
@trade1_in = false
@trade2_in = false
@trade3_in = false

@running_results = []



def get_moving_average(ma, results_array)
  array = results_array.last(ma)
  ma1_temp = 0
  count = 0
  while count < ma
    temp = array[count]
    ma1_temp = ma1_temp + temp.to_f
    count = count + 1
  end
  ma1 = ma1_temp / ma
  puts "moving average for " + ma.to_s + " was: " + ma1.to_s
  return ma1
end

def get_poloniex_ticker
  flag = false
  # call poloniex and get all ticket data, and parse to JSON
  while flag == false
    begin
      raw_results = HTTParty.get("https://poloniex.com/public?command=returnTicker")
      a = raw_results.parsed_response
      flag = true
    rescue
      raw_results = HTTParty.get("https://poloniex.com/public?command=returnTicker")
      a = raw_results.parsed_response
      flag = true
    end
  end
  return a['USDT_BTC']['last'].to_f
end

def update_usdt_btc_pair

end

def buy_or_sell(value1, value2)
  buy_or_sell = 'null'
  if value1 >= value2
    buy_or_sell = true
  elsif value1 < value2
    buy_or_sell = false
  else
    puts "BROKEN - WAS NOT ABLE TO DETERMINE BUY OR SELL STATUS FROM MOVING AVERAGES"
  end
  return buy_or_sell
end

def calculate_conclusion_and_act(value1, value2, flag, comment)
  # this method calculates whether to trade or not
  # based on the moving averages it has been pass

  # puts "calculating moving average for " + comment
  if flag == false
    return_value = buy_or_sell(value1, value2)
  elsif flag == true
    return_value = buy_or_sell(value1, value2)
  else
    puts "BROKEN -- COULD NOT DETERMINE THE FLAG STATUS TO KNOW IF WE WERE IN OR OUT OF CURRENT TRADE POSITION"
  end
  return return_value
end

def calculate_trade1
  # calculate moving averages and whether trade is responsible move
  ma_2min = get_moving_average(@ma_2_interval, @running_results)
  ma_7min = get_moving_average(@ma_7_interval, @running_results)
  trade1_before = @trade1_in
  trade_returns = 0
  @trade1_in = calculate_conclusion_and_act(ma_2min, ma_7min, @trade1_in, "2 and 7")
  current_price = get_poloniex_ticker
  if trade1_before == true && @trade_pot1_lastbuyprice > current_price && SHORTCIRCUIT_FLAG == true
    "The trade price went below the last buy price so saving our profits and selling"
    puts "SHORT CIRCUIT trading pot 1 and selling at at " + current_price.to_s
    puts "original buy price: " + @trade_pot1_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot1_lastbuyprice
    @trade_returns_pot1 = @trade_returns_pot1 + trade_returns
    @trade1_shortcircuit_counter = @trade1_shortcircuit_counter + 1
    @trade1_in = false
    if @trade_pot1_lastbuyprice > current_price
      @trade1_loss_counter = @trade1_loss_counter +1
      puts "LOSSER"
      puts trade_returns.to_s
      @trade1_loss_total = @trade1_loss_total + trade_returns
    elsif @trade_pot1_lastbuyprice  < current_price
      puts "WINNER"
      puts trade_returns.to_s
      @trade1_gains_counter = @trade1_gains_counter +1
    elsif @trade_pot1_lastbuyprice == current_price
      puts "NEUTRAL TRADE ON TRADE POT 1 - THIS TRADE SHOULD PROBABLY NOT HAVE BEEN MADE AS IT SOLD AS THE SAME AS THE BUY PRICE"
    else
      puts 'BROKEN - COULD NOT DETERMINE WINNING OR LOSING TRADE 1'
    end
  # act on the results
  elsif trade1_before == true && @trade1_in == true
    puts "trade 1 in and staying in"
    puts "orginal buy price: " + @trade_pot1_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot1_lastbuyprice
    puts "current profit on trade: " + trade_returns.to_s
    # do nothing
  elsif trade1_before == false && @trade1_in == true
    # order was bought, set purchase price
    puts "trading pot 1 bought at " + current_price.to_s
    # reset last price price as we just bought some
    @trade_pot1_lastbuyprice = current_price
  elsif trade1_before == true && @trade1_in == false
    # order was sold, set purchase price
    puts "trading pot 1 sold at " + current_price.to_s
    puts "original buy price: " + @trade_pot1_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot1_lastbuyprice
    @trade_returns_pot1 = @trade_returns_pot1 + trade_returns
    if @trade_pot1_lastbuyprice > current_price
      @trade1_loss_counter = @trade1_loss_counter +1
      puts "LOSSER"
      puts trade_returns.to_s
      @trade1_loss_total = @trade1_loss_total + trade_returns
    elsif @trade_pot1_lastbuyprice  < current_price
      puts "WINNER"
      puts trade_returns.to_s
      @trade1_gains_counter = @trade1_gains_counter +1
    elsif @trade_pot1_lastbuyprice == current_price
      puts "NEUTRAL TRADE ON TRADE POT 1 - THIS TRADE SHOULD PROBABLY NOT HAVE BEEN MADE AS IT SOLD AS THE SAME AS THE BUY PRICE"
    else
      puts 'BROKEN - COULD NOT DETERMINE WINNING OR LOSING TRADE 1'
    end
  elsif trade1_before == false && @trade1_in == false
    puts "trade 1 out and staying out"
  else
    puts "BROKEN BROKEN BROKEN BROKEN CANT DETERMINE TRADE 1 CALCULATION"
  end
end


def calculate_trade2
  ma_2min = get_moving_average(@ma_2_interval, @running_results)
  ma_30min = get_moving_average(@ma_30_interval, @running_results)
  trade2_before = @trade2_in
  trade_returns = 0
  current_price = get_poloniex_ticker
  @trade2_in = calculate_conclusion_and_act(ma_2min, ma_30min, @trade2_in, "2 and 30")
  if trade2_before == true && @trade_pot2_lastbuyprice > current_price && SHORTCIRCUIT_FLAG == true
    "The trade price went below the last buy price so saving our profits and selling"
    puts "SHORT CIRCUIT trading pot 2 and selling at at " + current_price.to_s
    puts "original buy price: " + @trade_pot2_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot2_lastbuyprice
    @trade_returns_pot2 = @trade_returns_pot2 + trade_returns
    @trade2_shortcircuit_counter = @trade2_shortcircuit_counter + 1
    @trade2_in = false
    if @trade_pot2_lastbuyprice > current_price
      @trade2_loss_counter = @trade2_loss_counter +1
      puts "LOSSER"
      puts trade_returns.to_s
      @trade2_loss_total = @trade2_loss_total + trade_returns
    elsif @trade_pot2_lastbuyprice  < current_price
      puts "WINNER"
      puts trade_returns.to_s
      @trade2_gains_counter = @trade2_gains_counter +1
    elsif @trade_pot2_lastbuyprice == current_price
      puts "NEUTRAL TRADE ON TRADE POT 2 - THIS TRADE SHOULD PROBABLY NOT HAVE BEEN MADE AS IT SOLD AS THE SAME AS THE BUY PRICE"
    else
      puts 'BROKEN - COULD NOT DETERMINE WINNING OR LOSING TRADE 1'
    end
    # act on the results
  elsif trade2_before == true && @trade2_in == true
    puts "trade 2 in and staying in"
    puts "orginal buy price: " + @trade_pot2_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot2_lastbuyprice
    puts "current profit on trade: " + trade_returns.to_s
  elsif trade2_before == false && @trade2_in == true
    # order was bought, set purchase price
    current_price = get_poloniex_ticker
    puts "trading pot 2 bought at " + current_price.to_s
    # reset last price price as we just bought some
    @trade_pot2_lastbuyprice = current_price
  elsif trade2_before == true && @trade2_in == false
    # order was sold, set purchase price
    puts "trading pot 2 sold at " + current_price.to_s
    puts "original buy price: " + @trade_pot2_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot2_lastbuyprice
    @trade_returns_pot2 = @trade_returns_pot2 + trade_returns
    if @trade_pot2_lastbuyprice > current_price
      @trade2_loss_counter = @trade2_loss_counter +1
      puts "LOSER"
      puts trade_returns.to_s
      @trade2_loss_total = @trade2_loss_total + trade_returns
    elsif @trade_pot2_lastbuyprice  < current_price
      puts "WINNER"
      puts trade_returns.to_s
      @trade2_gains_counter = @trade2_gains_counter +1
    elsif @trade_pot2_lastbuyprice == current_price
      puts "NEUTRAL TRADE ON TRADE POT 2 - THIS TRADE SHOULD PROBABLY NOT HAVE BEEN MADE AS IT SOLD AS THE SAME AS THE BUY PRICE"
    else
      puts 'BROKEN - COULD NOT DETERMINE WINNING OR LOSING TRADE ON TRADE 2'
    end
  elsif trade2_before == false && @trade2_in == false
    puts "trade 2 out and staying out"
  else
    puts "BROKEN BROKEN BROKEN BROKEN CANT DETERMINE TRADE 2 CALCULATION"
  end
end

def calculate_trade3
  ma_7min = get_moving_average(@ma_7_interval, @running_results)
  ma_30min = get_moving_average(@ma_30_interval, @running_results)
  trade3_before = @trade3_in
  trade_returns = 0
  current_price = get_poloniex_ticker
  @trade3_in = calculate_conclusion_and_act(ma_7min, ma_30min, @trade3_in, "7 and 30")
  if trade3_before == true && @trade_pot3_lastbuyprice > current_price && SHORTCIRCUIT_FLAG == true
    "The trade price went below the last buy price so saving our profits and selling"
    puts "SHORT CIRCUIT trading pot 3 and selling at at " + current_price.to_s
    puts "original buy price: " + @trade_pot3_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot3_lastbuyprice
    @trade3_shortcircuit_counter = @trade3_shortcircuit_counter + 1
    @trade_returns_pot3 = @trade_returns_pot3 + trade_returns
    @trade3_in = false
    if @trade_pot3_lastbuyprice > current_price
      @trade3_loss_counter = @trade3_loss_counter +1
      puts "LOSSER"
      puts trade_returns.to_s
      @trade3_loss_total = @trade3_loss_total + trade_returns
    elsif @trade_pot3_lastbuyprice  < current_price
      puts "WINNER"
      puts trade_returns.to_s
      @trade3_gains_counter = @trade3_gains_counter +1
    elsif @trade_pot3_lastbuyprice == current_price
      puts "NEUTRAL TRADE ON TRADE POT 3 - THIS TRADE SHOULD PROBABLY NOT HAVE BEEN MADE AS IT SOLD AS THE SAME AS THE BUY PRICE"
    else
      puts 'BROKEN - COULD NOT DETERMINE WINNING OR LOSING TRADE 3'
    end
    # act on the results
  elsif trade3_before == true && @trade3_in == true
    puts "trade 3 in and staying in"
    puts "orginal buy price: " + @trade_pot3_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot3_lastbuyprice
    puts "current profit on trade: " + trade_returns.to_s
  elsif trade3_before == false && @trade3_in == true
    # order was bought, set purchase price
    current_price = get_poloniex_ticker
    puts "trading pot 3 bought at " + current_price.to_s
    # reset last price price as we just bought some
    @trade_pot3_lastbuyprice = current_price
  elsif trade3_before == true && @trade3_in == false
    # order was sold, set purchase price
    puts "trading pot 3 sold at " + current_price.to_s
    puts "original buying price: " + @trade_pot3_lastbuyprice.to_s
    trade_returns = current_price - @trade_pot3_lastbuyprice
    @trade_returns_pot3 = @trade_returns_pot3 + trade_returns
    puts "trading pot 3 running total: " + @trade_returns_pot3.to_s
    if @trade_pot3_lastbuyprice > current_price
      @trade3_loss_counter = @trade3_loss_counter +1
      puts "LOSER"
      puts trade_returns.to_s
      @trade3_loss_total = @trade3_loss_total + trade_returns
    elsif @trade_pot3_lastbuyprice  < current_price
      puts "WINNER"
      puts trade_returns.to_s
      @trade3_gains_counter = @trade3_gains_counter +1
    elsif @trade_pot3_lastbuyprice == current_price
      puts "NEUTRAL TRADE ON TRADE POT 3 - THIS TRADE SHOULD PROBABLY NOT HAVE BEEN MADE AS IT SOLD AS THE SAME AS THE BUY PRICE"
    else
      puts 'BROKEN - COULD NOT DETERMINE WINNING OR LOSING TRADE ON TRADE 3'
    end
  elsif trade3_before == false && @trade3_in == false
    puts "trade 3 out and staying out"
  else
    puts "BROKEN BROKEN BROKEN BROKEN CANT DETERMINE TRADE 3 CALCULATION"
  end
end

def prime_initial_data
  puts "collecting data ......."
  while @running_results.length < @ma_30_interval  # this is the largest interval so we use that as the limit
    @running_results.push(get_poloniex_ticker)
    sleep TIME_PERIOD
    puts "still collecting data ......."
    puts "on data collection enrty " + @running_results.length.to_s + " of " + @ma_30_interval.to_s
  end
end



create_timing_and_sample_sizes
prime_initial_data
count = 0
run = true
run_counter = 0
while run_counter < @run_timer
  count = count + 1
  # remove the first entry before getting new one
  @running_results.delete_at(0)
  # get new values
  @running_results.push(get_poloniex_ticker)


  #puts results_array
  puts "============================================"
  puts @running_results.last.to_s
  calculate_trade1
  puts "--------------------------------------------"
  calculate_trade2
  puts "--------------------------------------------"
  calculate_trade3
  puts "--------------------------------------------"

  sleep TIME_PERIOD



  total_pot = @trade_returns_pot1 + @trade_returns_pot2 + @trade_returns_pot3
  total_pot = total_pot.round(2)
  puts "total trading profit/loss pot: " + total_pot.to_s

  if count == 10
    puts "------------------------------------------"
    puts "time for profit and loss trade update"
    puts "TRADE POT 1"
    puts "gains: " + @trade1_gains_counter.to_s
    puts "losses: " + @trade1_loss_counter.to_s
    puts "losses total: " + @trade1_loss_total.to_s
    puts "short circuits: " + @trade2_shortcircuit_counter.to_s
    puts "total profit/loss: " + @trade_returns_pot1.to_s
    puts "TRADE POT 2"
    puts "gains: " + @trade2_gains_counter.to_s
    puts "losses: " + @trade2_loss_counter.to_s
    puts "losses total: " + @trade2_loss_total.to_s
    puts "short circuits: " + @trade2_shortcircuit_counter.to_s
    puts "total profit/loss: " + @trade_returns_pot2.to_s
    puts "TRADE POT 3"
    puts "gains: " + @trade3_gains_counter.to_s
    puts "losses: " + @trade3_loss_counter.to_s
    puts "losses total: " + @trade3_loss_total.to_s
    puts "short circuits: " + @trade3_shortcircuit_counter.to_s
    puts "total profit/loss: " + @trade_returns_pot3.to_s
    count = 0
  end

  #puts "trading pot 1 running total: " + @trade_returns_pot1.to_s
  #puts "trading pot 2 running total: " + @trade_returns_pot2.to_s
  #puts "trading pot 3 running total: " + @trade_returns_pot3.to_s
  run_counter = run_counter + 1
  puts "on iteration: " + run_counter.to_s + " of " + @run_timer.to_s
end



