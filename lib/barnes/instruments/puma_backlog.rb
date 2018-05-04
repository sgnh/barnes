# frozen_string_literal: true

module Barnes
  module Instruments
    class PumaBacklog
      def initialize(sample_rate=nil)
      end

      def valid?
        defined?(Puma) &&
          Puma.respond_to?(:stats) &&
          ENV["DYNO"] && ENV["DYNO"].start_with?("web")
      end

      def start!(state)
        require 'multi_json'
      end

      def json_stats
        MultiJson.load(Puma.stats || "{}")

      # Puma loader has not been initialized yet
      rescue NoMethodError => e
        raise e unless e.message =~ /nil/
        raise e unless e.message =~ /stats/
        return {}
      end

      # For single worker process use value directly
      # for multiple workers sum backlog.
      #
      # https://github.com/puma/puma/pull/1532
      def stat_value_from_key(key)
        stats = json_stats

        value = stats[key]
        return value if value

        value = stats["worker_status"].map do |worker_status|
          worker_status["last_status"][key] || 0
        end.reduce(0, :+)

        return value
      end

      def instrument!(state, counters, gauges)
        return if json_stats.empty?

        gauges[:'pool.capacity']    = stat_value_from_key("pool_capacity")
        gauges[:'backlog.requests'] = stat_value_from_key("backlog")
      end
    end
  end
end
