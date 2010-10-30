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
      to = opts[:to] || {}
      except = opts[:except] || {}
      
      # Move to new syntax
      if opts[:to] || opts[:except]
        deprecation_warning "Using of :to and :except will be removed in next version - please move to new syntax."        
      end
      to[:client]   ||= opts[:client]
      to[:clients]  ||= opts[:clients]
      to[:channel]  ||= opts[:channel]
      to[:channels] ||= opts[:channels]
      # end of new syntax

      unless to.is_a?(Hash) && except.is_a?(Hash)
        raise "recipiend data should be in hash format"
      end

      to_clients = to[:client] || to[:clients]
      to_channels = to[:channel] || to[:channels]
      except_clients = except[:client] || except[:clients]
      except_channels = except[:channel] || except[:channels]

      # If clients or channels are non-nil but empty then there's no users to target message
      return if (to_clients.is_a?(Array) && to_clients.empty?) || (to_channels.is_a?(Array) && to_channels.empty?)

      hash = {
        :command  => :broadcast,
        :body     => data,
        :to => {
          :clients  => to_clients,
          :channels => to_channels,
        },
        :except => {
          :clients  => except_clients,
          :channels => except_channels,
        }
      }

      [:to, :except].each do |type|
        hash[type].reject! { |key,val| val.nil? || (type == :except && val.empty?)}
        hash.delete(type) if hash[type].empty?
      end

      send_data(hash)
    end

    def send_query(type)
      hash = {
        :command  => :query,
        :type     => type
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
        res.collect {|r| JSON.parse(r)["body"] }
      else
        true
      end
    end

  end

end