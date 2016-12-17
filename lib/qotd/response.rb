module Qotd
  class Response
    attr_reader :command, :resource, :resource_id

    CRLF    = "\r\n"
    HEADER  = "OK: %s"
    ERROR   = "FAIL: %s"
    VRESP   = "QOTD SERVER VERSION %s"

    def initialize(command: command, resource: resource,
                   resource_id: resource_id)
      @command     = command
      @resource    = resource
      @resource_id = resource_id
    end

    def self.create(command: command, resource: resource,
                    resource_id: resource_id)
      new(command: command, resource: resource,
          resource_id: resource_id).create
    end

    def self.error_response(reason)
      close(ERROR % reason)
    end

    def self.close(msg)
      [msg, CRLF].join
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
      close(_header(resource, resource_id))
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
      close(_authors)
    end

    def version
      close(_version)
    end

    def quote
      close(_quote)
    end

    def error_response(reason)
      self.class.error_response(reason)
    end

    def close(msg)
      self.class.close(msg)
    end

    def _quote
      Qotd::Lookup.quote_of_the_day(author_id: resource_id)
    end

    def _authors
      Qotd::Lookup.authors.join(",")
    end

    def _version
      VRESP % Qotd::VERSION
    end

    def _header(resource, resource_id)
      HEADER % [resource, resource_id].compact.join(" ")
    end
  end
end
