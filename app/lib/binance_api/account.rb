require 'binance'

module BinanceAPI
  module Account
    include BinanceAPI::Helpers

    def account
      safe_api_call do
        client.account(**default_params)[:balances]
          .select { |e| e[:asset].exclude?('LD') }
          .map { |h| { asset: h[:asset], amount: h.delete(:free).to_f } }
      end
    end
    add_method_tracer :account, 'Custom/BinanceAPI::Account#account'
  end
end
