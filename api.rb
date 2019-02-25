require 'net/http'
require 'json'

# idea is to define a method_missing which can create on the go methods like 'convert_to_EUR', 'convert_to_MXN'

class Currency
    attr_accessor :brl_value

    @brl_value = 0.0
    @@valid_currency_c = ['USD', 'CAD', 'EUR', 'AED', 'AFN', 'ALL', 'AMD', 'ARS', 'AUD', 'AZN', 'BAM', 'BDT', 'BGN', 
                          'BHD', 'BIF', 'BND', 'BOB', 'BRL', 'BWP', 'BYR', 'BZD', 'CDF', 'CHF', 'CLP', 'CNY', 'COP',
                          'CRC', 'CVE', 'CZK', 'DJF', 'DKK', 'DOP', 'DZD', 'EEK', 'EGP', 'ERN', 'ETB', 'GBP', 'GEL',
                          'GHS', 'GNF', 'GTQ', 'HKD', 'HNL', 'HRK', 'HUF', 'IDR', 'ILS', 'INR', 'IQD', 'IRR', 'ISK',
                          'JMD', 'JOD', 'JPY', 'KES', 'KHR', 'KMF', 'KRW', 'KWD', 'KZT', 'LBP', 'LKR', 'LTL', 'LVL',
                          'LYD', 'MAD', 'MDL', 'MGA', 'MKD', 'MMK', 'MOP', 'MUR', 'MXN', 'MYR', 'MZN', 'NAD', 'NGN',
                          'NIO', 'NOK', 'NPR', 'NZD', 'OMR', 'PAB', 'PEN', 'PHP', 'PKR', 'PLN', 'PYG', 'QAR', 'RON',
                          'RSD', 'RUB', 'RWF', 'SAR', 'SDG', 'SEK', 'SGD', 'SOS', 'SYP', 'THB', 'TND', 'TOP', 'TRY',
                          'TTD', 'TWD', 'TZS', 'UAH', 'UGX', 'UYU', 'UZS', 'VEF', 'VND', 'XAF', 'XOF', 'YER', 'ZAR',
                          'ZMK']

    def method_missing(m, *args, &block)
        puts "Delegating #{m}"
        if m.to_s =~ /^convert_to_(...)$/
            code = $1
            if @@valid_currency_c.include? code
                object.send(convert_to, code)
            end
        end
    end

    def convert_to(currency)
        url = "https://api.exchangeratesapi.io/latest?base=BRL"
        uri = URI(url)
        response = JSON.parse(Net::HTTP.get(uri))
        response["rates"][currency] * @brl_value
    end


end

money = Currency.new()
money.brl_value = 33.5
puts money.convert_to("USD")
money.convert_to_USD
