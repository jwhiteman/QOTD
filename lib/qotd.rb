require "socket"
require "qotd/version"
require "qotd/quotes"
require "qotd/lookup"
require "qotd/request"
require "qotd/response"
require "qotd/strategy"
require "qotd/config"

module Qotd
  def self.start(config: CONFIG)
    socket  = Socket.new(:INET, :STREAM)
    address = Socket.pack_sockaddr_in(config.port, config.host)

    socket.setsockopt(:IPPROTO_TCP, :TCP_NODELAY, 1)
    socket.setsockopt(:SOCKET, :REUSEADDR, 1)

    socket.bind(address)

    print "listening on #{config.port} (pid #{$$})\n" if config.verbose

    socket.listen(config.lqueue)

    strategy = config.strategy
    strategy.run(socket: socket, config: config)
  ensure
    socket.close rescue nil
  end
end
