require 'binance'

module BinanceAPI
  module Investments
    include BinanceAPI::Helpers

    def dual_investments
      safe_api_call do
        client.dual_investments(**default_params, status: 'PURCHASE_SUCCESS', size: 100)[:list]
      end
    end
    add_method_tracer :dual_investments, 'Custom/BinanceAPI::Investments#dual_investments'

    def flexible_product_position
      safe_api_call do
        res = client.flexible_product_position(**default_params, size: 100)
        res[:rows].each_with_object([]) do |h, arr|
          arr << { asset: h[:asset], amount: h[:totalAmount].to_f }
        end
      end
    end
    add_method_tracer :flexible_product_position, 'Custom/BinanceAPI::Investments#flexible_product_position'

    def locked_product_position
      safe_api_call do
        res = client.locked_product_position(**default_params, size: 100)
        res[:rows].each_with_object([]) do |h, arr|
          arr << { asset: h[:asset], amount: h[:amount].to_f }
        end
      end
    end
    add_method_tracer :locked_product_position, 'Custom/BinanceAPI::Investments#locked_product_position'

    def flexible_rewards_history(asset: nil, end_time: nil)
      safe_api_call do
        params = time_range_params(end_time).merge(asset:, type: 'ALL')
        client.flexible_rewards_history(**default_params, **params)[:rows]
      end
    end
    add_method_tracer :flexible_rewards_history, 'Custom/BinanceAPI::Investments#flexible_rewards_history'

    def locked_rewards_history(end_time: nil)
      safe_api_call do
        params = time_range_params(end_time).merge(size: 100, type: 'ALL')
        client.locked_rewards_history(**default_params, **params)[:rows]
      end
    end
    add_method_tracer :locked_rewards_history, 'Custom/BinanceAPI::Investments#locked_rewards_history'

    def flexible_subscription_record(end_time: nil)
      safe_api_call do
        params = time_range_params(end_time).merge(size: 100)
        client.flexible_subscription_record(**default_params, **params)[:rows]
      end
    end
    add_method_tracer :flexible_subscription_record, 'Custom/BinanceAPI::Investments#flexible_subscription_record'
  end
end
