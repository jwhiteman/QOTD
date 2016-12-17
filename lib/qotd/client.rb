require "ostruct"
module Qotd
  module Client
    extend self

    def make_request(config: CONFIG, request: request, num_requests: 1)
      socket = Socket.new(:INET, :STREAM)
      addr   = Socket.pack_sockaddr_in(config.port, config.host)

      socket.connect(addr)

      num_requests.times do
        socket.write(request)

        @response = socket.readpartial(config.chunk)

        yield @response if block_given?
      end

      header, body = @response.split("\r\n")

      OpenStruct.new({header: header, body: body})
    rescue Errno::ECONNREFUSED
      yield "ECONNREFUSED" if block_given?
      socket.close

      retry
    rescue Errno::ECONNRESET
      yield "ECONNRESET" if block_given?
      socket.close

      sleep 0.05
      retry
    rescue Errno::EPIPE
      yield "EPIPE" if block_given?
      socket.close

      retry
    rescue Errno::EPROTOTYPE
      yield "EPROTOTYPE" if block_given?
      socket.close

      retry
    rescue Errno::ETIMEDOUT
      yield "ETIMEDOUT" if block_given?
      socket.close

      retry
    ensure
      socket.close rescue nil
    end
    alias_method :make_requests, :make_request

  end
end
