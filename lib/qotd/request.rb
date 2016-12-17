module Qotd
  class Request
    attr_reader :request

    COMMANDS  = %w(GET).freeze
    RESOURCES = %w(authors version quote).freeze

    def initialize(request)
      @request = request.chomp
    end

    def self.process(request)
      new(request).process
    end

    def process
      command, resource, resource_id = request.split

      if valid?(command, resource)
        build_response(command, resource, resource_id)
      else
        error_response
      end
    end

    def valid?(command, resource)
      valid_command?(command) && valid_resource?(resource)
    end

    def commands
      COMMANDS
    end

    def resources
      RESOURCES
    end

    def valid_command?(command)
      has?(commands, command)
    end

    def valid_resource?(resource)
      has?(resources, resource)
    end

    def has?(collection, element)
      collection.include?(element)
    end

    def build_response(command, resource, resource_id)
      Qotd::Response.create(
        command:     command,
        resource:    resource,
        resource_id: resource_id
      )
    end

    def error_response
      Qotd::Response.error_response("INVALID REQUEST")
    end
  end
end
