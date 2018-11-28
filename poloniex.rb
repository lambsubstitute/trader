#require './httparty'
require 'httparty'
require 'json'


TIME_PERIOD = 5

@trade_returns_pot1 = 0
@trade_returns_pot2 = 0
@trade_returns_pot3 = 0

@trade1_buyprice = 0
@trade2_buyprice = 0
@trade3_buyprice = 0

@trade_pot1_lastbuyprice = 0
@trade_pot2_lastbuyprice = 0
@trade_pot3_lastbuyprice = 0


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
  #puts "moving average for " + ma.to_s + " was: " + ma1.to_s
  return ma1
end

def get_poloniex_ticker
  # call poloniex and get all ticket data, and parse to JSON
  raw_results = HTTParty.get("https://poloniex.com/public?command=returnTicker")
  a = raw_results.parsed_response
  return a['USDT_BTC']['last'].to_f
end

def update_usdt_btc_pair

end

def calculate_conclusion_and_act(value1, value2, flag, comment)
 # puts "calculating moving average for " + comment
  if flag == false
    if value1 > value2
     # puts "BUYING NOW"
      return_value = true
    else
    #  puts "STAYING OUT"
      return_value = false
    end
  else
    if value1 > value2
    #  puts "STAYING IN"
      return_value = true
    else
    #  puts "SELLING NOW"
      return_value = false
    end
  end
  return return_value
end

def calculate_trade1()
  ma_2min = get_moving_average(2, @running_results)
  ma_7min = get_moving_average(7, @running_results)
  trade1_before = @trade1_in
  @trade1_in = calculate_conclusion_and_act(ma_2min, ma_7min, @trade1_in, "2 and 7")
  if trade1_before == true && @trade1_in == true
    puts "trade 1 in and staying in"
    # do nothing
  elsif trade1_before == false && @trade1_in == true
    # order was bought, set purchase price
    current_price = get_poloniex_ticker
    puts "trading pot 1 bought at " + current_price.to_s
    # reset last price price as we just bought some
    @trade_pot1_lastbuyprice = current_price
  elsif trade1_before == true && @trade1_in == false
    # order was sold, set purchase price
    current_price = get_poloniex_ticker
    puts "trading pot 1 sold at " + current_price.to_s
    puts "original buy price: " + @trade_pot1_lastbuyprice.to_s
    @trade_returns_pot1 = @trade_returns_pot1 + (current_price.to_i - @trade_pot1_lastbuyprice)
  elsif trade1_before == false && @trade1_in == false
    puts "trade 1 out and staying out"
  else
    puts "BROKEN BROKEN BROKEN BROKEN CANT DETERMINE TRADE 1 CALCULATION"
  end
end

def calculate_trade2
  ma_2min = get_moving_average(2, @running_results)
  ma_30min = get_moving_average(30, @running_results)
  trade2_before = @trade2_in
  @trade2_in = calculate_conclusion_and_act(ma_2min, ma_30min, @trade2_in, "2 and 30")
  if trade2_before == true && @trade2_in == true
    puts "trade 2 in and staying in"
  elsif trade2_before == false && @trade2_in == true
    # order was bought, set purchase price
    current_price = get_poloniex_ticker
    puts "trading pot 2 bought at " + current_price.to_s
    # reset last price price as we just bought some
    @trade_pot2_lastbuyprice = current_price
  elsif trade2_before == true && @trade2_in == false
    # order was sold, set purchase price
    current_price = get_poloniex_ticker
    puts "trading pot 2 sold at " + current_price.to_s
    puts "original buy price: " + @trade_pot2_lastbuyprice.to_s
    @trade_returns_pot2 = @trade_returns_pot2 + (current_price.to_i - @trade_pot2_lastbuyprice)
  elsif trade2_before == false && @trade2_in == false
    puts "trade 2 out and staying out"
  else
    puts "BROKEN BROKEN BROKEN BROKEN CANT DETERMINE TRADE 2 CALCULATION"
  end
end

def calculate_trade3
  ma_7min = get_moving_average(7, @running_results)
  ma_30min = get_moving_average(30, @running_results)
  trade3_before = @trade3_in
  @trade3_in = calculate_conclusion_and_act(ma_7min, ma_30min, @trade3_in, "7 and 30")
  if trade3_before == true && @trade3_in == true
    puts "trade 3 in and staying in"
  elsif trade3_before == false && @trade3_in == true
    # order was bought, set purchase price
    current_price = get_poloniex_ticker
    puts "trading pot 3 bought at " + current_price.to_s
    # reset last price price as we just bought some
    @trade_pot3_lastbuyprice = current_price
  elsif trade3_before == true && @trade3_in == false
    # order was sold, set purchase price
    current_price = get_poloniex_ticker
    puts "trading pot 3 sold at " + current_price.to_s
    puts "original buying price: " + @trade_pot3_lastbuyprice.to_s
    @trade_returns_pot3 = @trade_returns_pot3 + (current_price.to_i - @trade_pot3_lastbuyprice)
    puts "trading pot 3 running total: " + @trade_returns_pot3.to_s
  elsif trade3_before == false && @trade3_in == false
    puts "trade 3 out and staying out"
  else
    puts "BROKEN BROKEN BROKEN BROKEN CANT DETERMINE TRADE 3 CALCULATION"
  end
end

def prime_initial_data
  puts "collecting data ......."
  while @running_results.length < 30
    @running_results.push(get_poloniex_ticker)
    sleep TIME_PERIOD
    puts "still collecting data ......."
    puts "on data collection enrty " + @running_results.length.to_s + " of 30"
  end
end




prime_initial_data

run = true
while run == true

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

  puts "trading pot 1 running total: " + @trade_returns_pot1.to_s
  puts "trading pot 2 running total: " + @trade_returns_pot2.to_s
  puts "trading pot 3 running total: " + @trade_returns_pot3.to_s

end



