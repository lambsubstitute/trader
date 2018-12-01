class Trade



  def calculate_trade(price_array, current_price, moving_average1, moving_average2)
    # calculate moving averages and whether trade is responsible move
    trade_decision = in_or_out?
  end


  def in_or_out?(moving_averages)
    ma_2min = moving_averages[0]
    ma_7min = moving_averages[1]
    if moving_averages[2] == 0
      ma_30min = 0
    else
      ma_30min =  moving_averages[2]
    end
    return buy_or_sell(ma_2min, ma_7min, ma_30min)
  end


  def buy_or_sell(value1, value2, value3)
    buy_or_sell = false
    if value3 != 0
      puts "using the moving averages #{value1},#{value2} and #{value3}"
      if (value1 >= value2) && (value1 >= value3) && (value2 > value3)
        buy_or_sell = true
      end
    else
      puts "using the moving averages #{value1} and #{value2}"
      if value1 > value2
        buy_or_sell = true
      elsif value1 < value2
          buy_or_sell = false
      else
         buy_or_sell = "stand"
        puts "price has had no movement so all averages are the same"
      end
    end
    return buy_or_sell
  end


end