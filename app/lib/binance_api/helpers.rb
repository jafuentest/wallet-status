module BinanceAPI
  module Helpers
    module_function

    MAX_RETRIES = 3
    RECV_WINDOW = 60_000
    TIME_RANGE = 3.months

    def default_params
      { recvWindow: RECV_WINDOW }
    end

    def safe_api_call(default: [], &)
      retries = 0
      begin
        res = NewRelic::Agent.disable_all_tracing(&)
      rescue Binance::Error => e
        retry if (retries += 1) <= MAX_RETRIES
        Rails.logger.error("Binance API error: #{e.message}")
      rescue StandardError => e
        Rails.logger.error("Unexpected error: #{e.message}")
      end

      res || default
    end

    def time_in_format(time)
      time.to_i * 1000
    end

    def time_range_params(end_time)
      return { endTime: nil } if end_time.blank?

      {
        startTime: time_in_format(end_time - TIME_RANGE),
        endTime: time_in_format(end_time),
      }
    end
  end
end
