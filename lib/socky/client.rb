# Mostly copied from pusher gem - they did great job and probably there are no reason to reinvent wheel ;)
autoload 'Logger', 'logger'
require File.expand_path(File.dirname(__FILE__)) + '/client/request'

module Socky
  class Client
    # All Socky errors descend from this class so you can easily rescue Socky errors
    #
    # @example
    #   begin
    #     socky_client.trigger!('an_event', :channel => 'my_channel', :data => {:some => 'data'})
    #   rescue Socky::Client::Error => e
    #     # Do something on error
    #   end
    class Error < RuntimeError; end
    class ArgumentError < Error; end
    class AuthenticationError < Error; end
    class ConfigurationError < Error; end
    class HTTPError < Error; attr_accessor :original_error; end
    
    class << self
      attr_writer :logger
      
      # @private
      def logger
        @logger ||= begin
          log = Logger.new($stdout)
          log.level = Logger::INFO
          log
        end
      end
    end
    
    attr_reader :uri, :secret
    attr_writer :logger
    
    # Create Socky::Client instance for later use.
    # This is usually needed only once per application so it's good idea to put it in global variable
    #
    # @example
    #   $socky_client = Socky::Client.new('http://example.org/http/my_app', 'my_secret')
    #
    # @param uri [String] Full uri(including app name) to Socky server
    # @param secret [String] Socky App secret
    #
    def initialize(uri, secret)
      @uri = URI.parse(uri)
      @secret = secret
    end
    
    # Trigger event
    #
    # @example
    #   begin
    #     $socky_client.trigger!('an_event', :channel => 'my_channe', :data => {:some => 'data'})
    #   rescue Socky::Client::Error => e
    #     # Do something on error
    #   end
    #
    # @param [String] event Event name to be triggered in javascript.
    # @param [Hash] opts Special options for request
    # @option opts [String] :channel Channel to which event will be sent
    # @option opts [Object] :data Data for trigger - Objects other than strings will be converted to JSON
    #
    # @raise [Socky::Client::Error] on invalid Socky Server response - see the error message for more details
    # @raise [Socky::Client::HTTPError] on any error raised inside Net::HTTP - the original error is available in the original_error attribute
    #
    def trigger!(event, opts = {})
      require 'net/http' unless defined?(Net::HTTP)
      require 'net/https' if (ssl? && !defined?(Net::HTTPS))
      
      channel = opts[:channel] || opts['channel']
      data = opts[:data] || opts['data']
      raise ArgumentError, 'no channel provided' unless channel
      
      request = Socky::Client::Request.new(self, event, channel, data)
      
      @http_sync ||= begin
        http = Net::HTTP.new(@uri.host, @uri.port)
        http.use_ssl = true if ssl?
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE if ssl?
        http
      end
      
      begin
        response = @http_sync.post(@uri.path,
          request.body, { 'Content-Type'=> 'application/json' })
      rescue Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED,
             Timeout::Error, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
             Net::ProtocolError => e
        error = Socky::Client::HTTPError.new("#{e.message} (#{e.class})")
        error.original_error = e
        raise error
      end
      
      return handle_response(response.code.to_i, response.body.chomp)
    end
    
    # Trigger event, catching and logging any errors.
    #
    # @note CAUTION! No exceptions will be raised on failure
    # @param (see #trigger!)
    #
    def trigger(event, opts = {})
      trigger!(event, opts)
    rescue Socky::Client::Error => e
      Socky::Client.logger.error("#{e.message} (#{e.class})")
      Socky::Client.logger.debug(e.backtrace.join("\n"))
      false
    end
    
    # Trigger event asynchronously using EventMachine::HttpRequest
    #
    # @param (see #trigger!)
    #
    # @return [EM::DefaultDeferrable]
    #   Attach a callback to be notified of success (with no parameters).
    #   Attach an errback to be notified of failure (with an error parameter
    #   which includes the HTTP status code returned)
    #
    # @raise [LoadError] unless em-http-request gem is available
    # @raise [Socky::Client::Error] unless the eventmachine reactor is running.
    #   You probably want to run your application inside a server such as thin.
    #
    def trigger_async(event, opts = {}, &block)
      unless defined?(EventMachine) && EventMachine.reactor_running?
        raise Error, "In order to use trigger_async you must be running inside an eventmachine loop"
      end
      require 'em-http' unless defined?(EventMachine::HttpRequest)
      
      channel = opts[:channel] || opts['channel']
      data = opts[:data] || opts['data']
      raise ArgumentError, 'no channel provided' unless channel
      
      request = Socky::Client::Request.new(self, event, channel, data)
      
      deferrable = EM::DefaultDeferrable.new
      
      http = EventMachine::HttpRequest.new(@uri).post({
        :timeout => 5, :body => request.body, :head => {'Content-Type'=> 'application/json'}
      })
      http.callback {
        begin
          handle_response(http.response_header.status, http.response.chomp)
          deferrable.succeed
        rescue => e
          deferrable.fail(e)
        end
      }
      http.errback {
        Socky::Client.logger.debug("Network error connecting to socky server: #{http.inspect}")
        deferrable.fail(Error.new("Network error connecting to socky server"))
      }
      
      deferrable
    end
    
    private
    
    def handle_response(status_code, body)
      case status_code
      when 202
        return true
      when 400
        raise Error, "Bad request: #{body}"
      when 401
        raise AuthenticationError, body
      when 404
        raise Error, "Resource not found: app name is probably invalid"
      else
        raise Error, "Unknown error (status code #{status_code}): #{body}"
      end
    end
    
    def ssl?
      @uri.scheme == 'https'
    end

  end
end
