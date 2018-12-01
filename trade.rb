class Trade



  def calculate_trade(price_array, current_price, moving_average1, moving_average2)
    # calculate moving averages and whether trade is responsible move
    trade_decision = in_or_out?
  end


  def in_or_out?(price_array, current_price, moving_averages)
    ma_2min = get_moving_average(moving_averages[0], price_array)
    ma_7min = get_moving_average(moving_averages[1], price_array)
    if moving_averages[2] == 0
      ma_30min = 0
    else
      ma_30min =  get_moving_average(moving_averages[2], price_array)
    end
    return buy_or_sell(ma_2min, ma_7min, ma_30min)
    # current_price = get_poloniex_ticker
  end


  def buy_or_sell(value1, value2, value3)
    buy_or_sell = false
    if value3 != 0
      if (value1 >= value2) && (value1 >= value3) && (value2 > value3)
        buy_or_sell = true
      end
    else
      if value1 > value2
        buy_or_sell = true
      else
        buy_or_sell = "stand"
        puts "price has had no movement so all averages are the same"
      end
    end
    return buy_or_sell
  end

  def calculate_conclusion_and_act_to_elete(value1, value2, flag, comment)
    # this method calculates whether to trade or not
    # based on the moving averages it has been pass
    if flag == false
      return_value = buy_or_sell(value1, value2)
    elsif flag == true
      return_value = buy_or_sell(value1, value2)
    else
      puts "BROKEN -- COULD NOT DETERMINE THE FLAG STATUS TO KNOW IF WE WERE IN OR OUT OF CURRENT TRADE POSITION"
    end
    return return_value
  end

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
    puts "moving average for #{ma} was: #{ma1.round(2)}"
    return ma1.round(2)
  end


end