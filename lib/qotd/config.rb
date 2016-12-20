require "ostruct"

module Qotd
  CONFIG = OpenStruct.new({
    strategy:      Qotd::Strategy::Evented,
    port:          10017,
    host:          "127.0.0.1",
    lqueue:        5,
    chunk:         512,
    verbose:       true,
    num_processes: 0,
    num_threads:   0
  }).freeze
end
