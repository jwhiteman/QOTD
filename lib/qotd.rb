require "socket"
require "qotd/version"
require "qotd/quotes"
require "qotd/lookup"
require "qotd/serial"
require "qotd/config"

module Qotd
  def self.start(config: CONFIG)
    socket  = Socket.new(:INET, :STREAM)
    address = Socket.pack_sockaddr_in(config.port, config.host)

    socket.setsockopt(:IPPROTO_TCP, :TCP_NODELAY, 1)
    socket.setsockopt(:SOCKET, :REUSEADDR, 1)

    socket.bind(address)

    print "listening on #{config.port} (pid #{$$})\n"

    socket.listen(config.lqueue)

    config.strategy.run(socket)
  ensure
    socket.close rescue nil
  end
end
