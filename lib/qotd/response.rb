module Qotd
  class Response
    attr_reader :command, :resource, :resource_id

    HEADER = "OK: %s\r\n".freeze
    ERROR  = "FAIL: %s\r\n".freeze

    def initialize(command: command, resource: resource, resource_id: resource_id)
      @command     = command
      @resource    = resource
      @resource_id = resource_id
    end

    def self.create(command: command, resource: resource, resource_id: resource_id)
      new(command: command, resource: resource, resource_id: resource_id).create
    end

    def self.error_response(reason)
      ERROR % reason
    end

    def create
      "".tap do |response|
        response << header(resource, resource_id)
        response << body(resource, resource_id)
      end
    rescue => e
      error_response(e)
    end

    def header(resource, resource_id)
      HEADER % [resource, resource_id].compact.join(" ")
    end

    def body(resource, resource_id)
      case resource
      when "authors" then authors
      when "version" then version
      when "quote"   then quote
      else
        raise "SERVER ERROR"
      end
    end

    def authors
      Qotd::Lookup.authors.join(",") << "\r\n"
    end

    def version
      "QOTD SERVER VERSION #{Qotd::VERSION}\r\n"
    end

    def quote
      (Qotd::Lookup.quote_of_the_day(author_id: resource_id) << "\r\n")
    end

    def error_response(reason)
      self.class.error_response(reason)
    end
  end
end
