module Qotd
  module Strategy
    class Evented
      attr_reader :socket, :config, :conns

      def initialize(socket: socket, config: config)
        @socket  = socket
        @config  = config
        @conns   = []
      end

      def self.run(socket: socket, config: config)
        new(socket: socket, config: config).run
      end

      class Connection
        attr_reader :socket, :config
        attr_accessor :request

        def initialize(socket, config)
          @socket = socket
          @config = config
        end

        def to_io
          socket
        end

        def writable?
          request.kind_of?(String) && !request.empty?
        end

        def do_write
          response = process_request

          socket.write(response)

          self.request = nil
        end

        def process_request
          Qotd::Request.process(request)
        end

        def do_read
          self.request = socket.readpartial(config.chunk)
        end

        def close
          socket.close
        end
      end

      def run
        trap(:INT) { exit }

        loop do
          readables, writables = IO.select(
            conns + [socket],
            conns
          )

          readables.each do |readable|
            if socket == readable
              connection, _ = socket.accept
              conns << Connection.new(connection, config)
            else
              begin
                readable.do_read
              rescue EOFError
                readable.close
                conns.delete(readable)
              end
            end
          end

          writables.select(&:writable?).each do |writable|
            writable.do_write
          end
        end
      end
    end
  end
end
