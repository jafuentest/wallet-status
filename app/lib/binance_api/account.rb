require 'binance'

module BinanceAPI
  module Account
    def account
      safe_api_call do
        client.account(recvWindow: self.class.recv_window)[:balances]
          .select { |e| e[:asset].exclude?('LD') }
          .map { |h| { asset: h[:asset], amount: h.delete(:free).to_f } }
      end
    end
    add_method_tracer :account, 'Custom/BinanceClient#account'
  end
end
