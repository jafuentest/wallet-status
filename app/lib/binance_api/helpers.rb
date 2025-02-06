module BinanceAPI
  module Helpers
    module_function

    TIME_RANGE = 3.months

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

    def safe_api_call(default: [], &)
      NewRelic::Agent.disable_all_tracing(&)
    rescue Binance::Error => e
      Rails.logger.error("Binance API error: #{e.message}")
      default
    rescue StandardError => e
      Rails.logger.error("Unexpected error: #{e.message}")
      default
    end
  end
end
