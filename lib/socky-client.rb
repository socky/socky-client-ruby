require 'json'
require 'logger'
require 'yaml'

require File.dirname(__FILE__) + '/socky-client/websocket'

module Socky

  class << self

    attr_accessor :config_path, :logger
    def config_path
      @config_path ||= 'socky_hosts.yml'
    end

    def config
      @config ||= YAML.load_file(config_path).freeze
    end

    def send(*args)
      options = normalize_options(*args)
      send_message(options.delete(:data), options)
    end

    def show_connections
      send_query(:show_connections)
    end

    def hosts
      config[:hosts]
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def deprecation_warning(msg)
      logger.warn "DEPRECATION WARNING: " + msg.to_s
    end

  private

    def normalize_options(data, options = {})
      case data
        when Hash
          options, data = data, nil
        when String, Symbol
          options[:data] = data
      else
        options.merge!(:data => data)
      end

      options[:data] = options[:data].to_s
      options
    end

    def send_message(data, opts = {})
      clients = opts[:client] || opts[:clients]
      channels = opts[:channel] || opts[:channels]

      # If clients or channels are non-nil but empty then there's no users to target message
      return if (clients.is_a?(Array) && clients.empty?) || (channels.is_a?(Array) && channels.empty?)

      hash = {
        :command  => :broadcast,
        :data     => data,
        :clients  => clients,
        :channels => channels
      }

      hash.reject! { |key,val| val.nil? }

      send_data(hash)
    end

    def send_query(type)
      hash = {
        :command  => :query,
        :data     => type
      }
      send_data(hash, true)
    end

    def send_data(hash, response = false)
      res = []
      hosts.each do |address|
        begin
          scheme = (address[:secure] ? "wss" : "ws")
          @socket = WebSocket.new("#{scheme}://#{address[:host]}:#{address[:port]}/?admin=1&client_secret=#{address[:secret]}")
          @socket.send(hash.to_json)
          res << @socket.receive if response
        rescue
          puts "ERROR: Connection to server at '#{scheme}://#{address[:host]}:#{address[:port]}' failed"
        ensure
          @socket.close if @socket && !@socket.tcp_socket.closed?
        end
      end
      if response
        res.collect {|r| JSON.parse(r)["data"] }
      else
        true
      end
    end

  end

end