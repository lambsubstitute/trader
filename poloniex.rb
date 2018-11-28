#require './httparty'
require 'httparty'


#Poloniex.setup do | config |
#  config.key = 'my api key'
##  config.secret = 'my secret token'
#end

  #results = Poloniex.new
  results = HTTParty.get("https://poloniex.com/public?command=returnTicker")
puts results