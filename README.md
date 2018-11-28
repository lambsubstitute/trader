# trader

# to do:
# 1. open connection to exchange - 
#   simple - DONE 
#   authenticated 
# 2. get data on exchange prices from last 30 minutes for each minutes closing price
# 3. from data create the moving averages for 2(a), 7(b), and 30(c) minute intervals
# 4. set values for stake
# 5. divide stake in to 3 for later use, trade pot 1 (tp1), trade pot 2(tp2), trade pot 3(tp3)
# 4. take moving averages and calculate the current state
#
# from initial state set the initial position(s)
# tp1Filled = null
# tp2Filled = null
# tp3Filled = null
#
#
# if a is above b
#   markerOrder(Purchase(tp1)
#   tp1Filled = true
# else
#   do nothing
# end
#
# if a is above c
#  markerOrder(Purchase(tp2)
#  tp2Filled = true
# else
#   do nothing
# end
#
# if b is above c
#   markerOrder(Purchase(tp3)
#   tp3Filled = true
# else
#   do nothing
# end
#
# update the moving averages
#
# while a is above b
#   do nothing
# else
#   marketOrder(Sell(tp1))
# end
#
# while a is above c
#   do nothing
# else
#   marketOrder(Sell(tp2))
# end
#
#
# while b is above c
#   do nothing
# else
#   marketOrder(sell(tp3))
# end
#
#
#
#
#

