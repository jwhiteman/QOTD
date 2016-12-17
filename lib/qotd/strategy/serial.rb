module Qotd
  module Strategy
    class Serial
      attr_reader :socket

      def initialize(socket: socket)
        @socket = socket
      end

      def self.run(socket)
        new(socket: socket).run
      end

      def run
        trap(:INT) do
          puts "shutting down #{$$}..."

          exit
        end

        loop do
          connection, _ = socket.accept

          print "new client: #{connection}\n"

          loop do
            begin
              request = connection.readpartial(1024)

              print "  request received: #{request}\n"

              connection.write("<some response: #{rand 1000}>")
            rescue EOFError => e
              print "closing client: #{connection}\n"
              connection.close
              break
            end
          end
        end
      end
    end
  end
end
