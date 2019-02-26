require 'net/http'
require 'json'

# idea is to define a method_missing which can create on the go methods like 'convert_to_EUR', 'convert_to_MXN'

class Currency
    attr_accessor :brl_value

    @@valid_currency_c = ['AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'EUR', 'GBP', 
                          'HKD', 'HRK', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', 'JPY', 'KRW', 'MXN',
                          'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'RUB', 'SEK', 'SGD', 'THB',
                          'TRY', 'USD', 'ZAR']
    def initialize    
        @brl_value = 0.0
    end   

    def method_missing(m, *args, &block)
        if m.to_s =~ /^convert_to_(...)$/
            code = $1.upcase
            puts "Trying to convert  to #{code}"
            if @@valid_currency_c.include? code
                send :convert_to, code
            else
                puts "Invalid currency code :("
            end
        else
            super
        end
    end

   
=begin     def respond_to_missing?(m, include_private = false)
        (m.to_s =~ /^convert_to_(...)$/ and @@valid_currency_c.include? $1.upcase) || super
    end
=end



    def convert_to(currency)
        url = "https://api.exchangeratesapi.io/latest?base=BRL"
        uri = URI(url)
        response = JSON.parse(Net::HTTP.get(uri))
        response["rates"][currency] * @brl_value
    end


end

## Testing our code
money = Currency.new()
money.brl_value = 33.5
puts "money.responds_to? :convert_to  == #{money.respond_to? :convert_to}" # Default method
puts "money.responds_to? :convert_to_PHP == #{money.respond_to? :convert_to_PHP}" # Uppercase currency code
puts "money.responds_to? :convert_to_jpy == #{money.respond_to? :convert_to_jpy}\n\n" # Lowercase currency code
puts "money.convert_to_PHP == #{money.convert_to_PHP}"