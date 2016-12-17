require "ostruct"
module Qotd
  module Client
    extend self

    def make_request(config: CONFIG, request: request)
      socket = Socket.new(:INET, :STREAM)
      addr   = Socket.pack_sockaddr_in(config.port, config.host)

      socket.connect(addr)

      socket.write(request)

      response = socket.readpartial(config.chunk)

      header, body = response.split("\r\n")

      OpenStruct.new({header: header, body: body})
    rescue Errno::ECONNREFUSED
      socket.close

      sleep 0.10
      retry
    rescue Errno::ECONNRESET
      socket.close

      retry
    rescue Errno::EPIPE
      socket.close

      retry
    ensure
      socket.close
    end
  end
end
