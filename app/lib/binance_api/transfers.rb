require 'binance'

module BinanceAPI
  module Transfers
    include BinanceAPI::Helpers

    def margin_transfer_history(start_time:, end_time:)
      safe_api_call do
        res = client.margin_transfer_history(
          **default_params,
          startTime: time_in_format(start_time),
          endTime: time_in_format(end_time)
        )

        res[:rows]
      end
    end
    add_method_tracer :margin_transfer_history, 'Custom/BinanceAPI::Transfers#margin_transfer_history'
  end
end
