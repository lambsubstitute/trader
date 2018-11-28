#require './httparty'
require 'httparty'
require 'json'


TIME_PERIOD = 30

def get_moving_average(ma, results_array)
  array = results_array.last(ma)
  ma1_temp = 0
  count = 0
  while count < ma
    temp = array[count]
    ma1_temp = ma1_temp + temp.to_i
    count = count + 1
  end
  ma1 = ma1_temp / ma
  puts ma1.to_s
  return ma1
end

def get_poloniex_ticker
  # call poloniex and get all ticket data, and parse to JSON
  raw_results = HTTParty.get("https://poloniex.com/public?command=returnTicker")
  a = raw_results.parsed_response
  return a['USDT_BTC']['last']
end

def update_usdt_btc_pair

end




results_array = []
run = true

puts "collecting data ......."
while results_array.length < 30
  results_array.push(get_poloniex_ticker)
  sleep TIME_PERIOD
  puts "still collecting data ......."
  puts "on data collection enrty " + results_array.length.to_s + " of 30"
end

while run == true
  # create base data - should take 7 minute
  # we take a data sample every 15 seconds which should be 4 times a minute
  # this requires all moving averages to be multipled by 4 in calculations

  #puts results_array

  # calculate moving averages
  ma1 = get_moving_average(2, results_array)
  ma2 = get_moving_average(7, results_array)
  ma3 = get_moving_average(30, results_array)

  puts "moving average price for 2 minutes is: " + ma1.to_s
  puts "moving average price for 7 minutes is: " + ma2.to_s
  puts "moving average price for 30 minutes is: " + ma3.to_s

  if ma1 > ma2
    puts "2 unit ma is above the 7 unit ma"
    puts "BUY NOW, OR STAY BOUGHT IN"
  else
    puts "2 unit ma is BELOW the 7 unit ma"
    puts "SELL NOW, OR STAY OUT"
  end

  if ma1 > ma3
    puts "2 unit ma is ABOVE the 30 unit ma"
    puts "BUY NOW, OR STAY BOUGHT IN"
  else
    puts "2 unit ma is BELOW the 30 unit ma"
    puts "SELL NOW, OR STAY OUT"
  end

  if ma2 > ma3
    puts "7 unit ma is ABOVE the 30 unit ma"
    puts "BUY NOW, OR STAY BOUGHT IN"
  else
    puts "7 unit ma is BELOW the 30 unit ma"
    puts "SELL NOW, OR STAY OUT"
  end



  sleep TIME_PERIOD

  # remove the first entry before getting new one
  results_array.delete_at(0)
  # get new values
  results_array.push(get_poloniex_ticker)
end



