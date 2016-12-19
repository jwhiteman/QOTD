module Qotd
  module Strategy
    class Pool
      attr_reader :socket, :config
      attr_accessor :workers

      def initialize(socket: socket, config: config)
        @socket  = socket
        @config  = config
        @workers = ThreadGroup.new
      end

      def self.run(socket: socket, config: config)
        new(socket: socket, config: config).run
      end

      def run
        # TODO: not sure if this helps or not
        trap(:INT) do
          workers.list.each(&:kill)
        end

        Thread.abort_on_exception = true

        config.num_threads.times do
          workers.add(spawn_thread(socket))
        end

        workers.list.each(&:join)
      end

      def spawn_thread(socket)
        Thread.new do
          loop do
            begin
              connection, _ = socket.accept

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
            rescue IOError
            rescue Errno::EBADF
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
