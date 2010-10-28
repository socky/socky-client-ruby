require 'yaml'
require 'json'

require File.dirname(__FILE__) + '/socky-client/websocket'

module Socky
  
  unless defined?(CONFIG_PATH)
    CONFIG_PATH = "socky_hosts.yml"
  end 

  CONFIG = YAML.load_file(CONFIG_PATH).freeze

  class << self

    def send(*args)
      options = normalize_options(*args)
      send_message(options.delete(:data), options)
    end

    def show_connections
      send_query(:show_connections)
    end

    def hosts
      CONFIG[:hosts]
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