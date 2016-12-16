$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "qotd"

def make_requests(config)
  socket = Socket.new(:INET, :STREAM)
  addr   = Socket.pack_sockaddr_in(config.port, config.host)

  socket.connect(addr)

  req = rand(1000)
  print "making request id #{req}...\n"
  socket.write("GET QUOTE #{req}")
  response = socket.readpartial(1024)
  print "  ~> " + response + "\n"
rescue Errno::ECONNRESET
  print "...RESET encountered\n"
  socket.close

  retry
rescue Errno::EPIPE
  print "...EPIPE encountered\n"
  socket.close

  retry
ensure
  socket.close
end

num_clients = ARGV[0] ? ARGV[0].to_i : 1
config      = Qotd::CONFIG

(1..num_clients).map do |n|
  Thread.new do
    make_requests(config)
  end
end.each(&:join)
