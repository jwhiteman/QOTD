require "ostruct"

module Qotd
  CONFIG = OpenStruct.new({
    strategy: Qotd::Strategy::Serial,
    port:     10017,
    host:     "127.0.0.1",
    lqueue:   5
  }).freeze
end
