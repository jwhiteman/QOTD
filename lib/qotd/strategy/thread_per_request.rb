module Qotd
  module Strategy
    class ThreadPerRequest
      attr_reader :socket, :config

      def initialize(socket: socket, config: config)
        @socket = socket
        @config = config
      end

      def self.run(socket: socket, config: config)
        new(socket: socket, config: config).run
      end

      def run
        trap(:INT) { exit }

        loop do
          connection, _ = socket.accept

          worker = Thread.new do
            begin
              loop do
                request  = connection.readpartial(config.chunk)
                response = process(request)
                connection.write(response)
              end
            rescue EOFError
            ensure
              connection.close
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
