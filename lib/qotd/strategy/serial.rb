module Qotd
  module Strategy
    class Serial
      attr_reader :socket, :config

      def initialize(socket:, config:)
        @socket = socket
        @config = config
      end

      def self.run(socket:, config:)
        new(socket: socket, config: config).run
      end

      def run
        trap(:INT) { exit }

        loop do
          connection, _ = socket.accept
          loop do
            begin
              request  = connection.readpartial(config.chunk)
              response = process(request)
              connection.write(response)
            rescue EOFError => e
              connection.close
              break
            end
          end
        end
      end

      def process(request)
        Qotd::Request.process(request)
      end
    end
  end
end
