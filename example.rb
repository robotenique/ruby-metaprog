require 'net/http'
require 'json'

# Logger implementation (show how attr_accessor works)
def logger *args
    # Log levels
    to_create = [:info, :warn, :error]

    # If arguments were provided, add methods to creation
    if args.length > 0
        to_create += args
    end

    # Get longest name
    max_len = to_create.map{ |level| level.length }.max

    # Create methods on the fly
    to_create.map do |level|
        define_method "log_#{level}" do |m|
            # Print right-padded log level and class
            puts "#{level}#{' ' * (max_len - level.length)} [#{self.class.name}]: #{m}"
        end
    end
end

# Class to store financial quantities
class Money
    # We have a value and a currency
    attr_accessor :value, :currency

    # Inject log functions at runtime (Add debug level)
    logger :debug

    # Valid currencies
    @@valid_currency_c = [:AUD, :BGN, :BRL, :CAD, :CHF, :CNY, :CZK, :DKK, :EUR, :GBP,
                          :HKD, :HRK, :HUF, :IDR, :ILS, :INR, :ISK, :JPY, :KRW, :MXN,
                          :MYR, :NOK, :NZD, :PHP, :PLN, :RON, :RUB, :SEK, :SGD, :THB,
                          :TRY, :USD, :ZAR]

    # Contructor with value & currency
    def initialize(value = 0.0, currency = :BRL)
        @value = value
        if @@valid_currency_c.include? currency.to_sym
            @currency = currency.to_sym
        else
            log_error "Invalid currency #{currency} :("
        end
    end

    # On missing method
    def method_missing(m, *args, &block)
        # If on the format 'to_XXX'
        if m.to_s =~ /^to_(...)$/
            code = $1.upcase
            log_debug "Trying to convert from #{@currency} to #{code}"
            # Verify currency code and 
            if @@valid_currency_c.include? code.to_sym
                convert_to code
            else
                log_warn "Invalid currency #{currency} :("
            end
        else
            super
        end
    end

=begin
    def respond_to_missing?(m, include_private = false)
        (m.to_s =~ /^to_(...)$/ and @@valid_currency_c.include? $1.upcase.to_sym) || super
    end
=end


    # Converts from current to given currency
    def convert_to(new_currency)
        url = "https://api.exchangeratesapi.io/latest?base=#{currency}"
        uri = URI(url)
        response = JSON.parse(Net::HTTP.get(uri))
        # Returns new money object
        Money.new(response["rates"][new_currency.to_s] * @value, new_currency.to_sym)
    end

    # Print currency prettily
    def to_s
        "#{value.round 2} [#{currency}]"
    end
end

## Testing our code

# responds_to tests
puts "responds_to tests:"
puts
money = Money.new(33.5)
puts "money.responds_to? :convert_to  == #{money.respond_to? :convert_to}" # Default method
puts "money.responds_to? :to_PHP == #{money.respond_to? :to_PHP}" # Uppercase currency code
puts "money.responds_to? :to_jpy == #{money.respond_to? :to_jpy}\n\n" # Lowercase currency code

# Money amounts
brl = Money.new(33.5)
usd = Money.new(33.5, :USD)

# Conversions
puts
puts
puts "Conversion tests:"
puts
puts "brl == #{brl}"
puts "usd == #{usd}"
puts
puts "brl.to_PHP == #{brl.to_PHP}"
puts
puts "usd.to_PHP == #{usd.to_PHP}"
puts
puts "usd.to_jpy == #{usd.to_jpy}"