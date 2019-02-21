require 'net/http'
require 'json'

# idea is to define a method_missing which can create on the go methods like 'convert_to_EUR', 'convert_to_MXN'

class CurrencyInfo
    attr_accessor :brl_value

    @brl_value = 0.0

    def convert_to(currency)
        url = "https://api.exchangeratesapi.io/latest?base=BRL"
        uri = URI(url)
        response = JSON.parse(Net::HTTP.get(uri))
        response["rates"][currency] * @brl_value
    end

end

money = CurrencyInfo.new()
money.brl_value = 33.5
puts money.convert_to("USD")
