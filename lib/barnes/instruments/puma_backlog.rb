# frozen_string_literal: true

module Barnes
  module Instruments
    class PumaBacklog
      def initialize(sample_rate=nil)
      end

      def valid?
        defined?(Puma) &&
          Puma.respond_to?(:stats) &&
          ENV["DYNO"].start_with?("web")
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

      # For single worker process use backlog directly
      # for multiple workers sum backlog.
      #
      # https://github.com/puma/puma/pull/1532
      def instrument!(state, counters, gauges)
        stats = self.json_stats
        return if stats.empty?

        backlog = stats["backlog"]
        if backlog.nil?
          backlog = stats["worker_status"].map do |worker_status|
            worker_status["last_status"]["backlog"]
          end.reduce(0, :+)
        end

        gauges[:'Ruby.Server.web.backlog.requests'] = backlog
      end
    end
  end
end
