class Trade



  def calculate_trade(price_array, current_price, moving_average1, moving_average2)
    # calculate moving averages and whether trade is responsible move
    trade_decision = in_or_out?


  end


  def in_or_out?(price_array, current_price, moving_averages)
    ma_2min = get_moving_average(moving_averages[0], price_array)
    ma_7min = get_moving_average(moving_averages[1], price_array)
    return buy_or_sell(ma_2min, ma_7min)
    # current_price = get_poloniex_ticker
  end

   def old_code
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


  def buy_or_sell(value1, value2)
    buy_or_sell = 'null'
    if value1 > value2
      buy_or_sell = true
    elsif value1 < value2
      buy_or_sell = false
    else
      buy_or_sell = "stand"
      puts "price has had no movement so all averages are the same"
    end
    return buy_or_sell
  end

  def calculate_conclusion_and_act(value1, value2, flag, comment)
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
    puts "moving average for " + ma.to_s + " was: " + ma1.to_s
    return ma1
  end


end