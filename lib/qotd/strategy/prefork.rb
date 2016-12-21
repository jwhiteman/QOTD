module Qotd
  module Strategy
    class Prefork
      attr_reader :socket, :config, :master
      attr_accessor :workers

      def initialize(socket:, config:)
        @socket  = socket
        @config  = config
        @master  = $$
        @workers = []
      end

      def self.run(socket:, config:)
        new(socket: socket, config: config).run
      end

      def run
        unless config.num_processes > 0
          raise "ERROR: num_processes must be greater than zero"
        end

        trap(:INT) do
          if $$ == master
            workers.each do |worker|
              begin
                Process.kill(:INT, worker)
              rescue Errno::ESRCH
              end
            end
          end

          exit
        end

        config.num_processes.times do
          workers << spawn_worker(socket)
        end

        loop do
          begin
            dead_worker_pid = Process.wait
            workers.delete(dead_worker_pid)
            workers << spawn_worker(socket)
          rescue Errno::ECHILD
          end
        end
      end

      def spawn_worker(socket)
        fork do
          loop do
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
          end
        end
      end

      def process(request)
        Qotd::Request.process(request)
      end
    end
  end
end
