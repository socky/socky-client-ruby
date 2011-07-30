require 'socky/authenticator'
require 'multi_json'
require 'crack/core_extensions' # Used for Hash#to_params

module Socky
  class Client
    class Request
      
      attr_reader :client, :event, :channel, :data

      def initialize(client, event, channel, data = nil)
        @client = client
        @event = event
        @channel = channel
        @data = MultiJson.encode(data)
      end
            
      def timestamp
        @timestamp ||= Time.now.to_i
      end
      
      def body
        content = {}
        content['event'] = @event
        content['channel'] = @channel
        content['timestamp'] = timestamp
        content['data'] = @data
        content['auth'] = auth_string
        content.to_params
      end
      
      private
      
      def auth_string
        Authenticator.authenticate({
          :connection_id => timestamp,
          :channel => @channel,
          :event => @event,
          :data => @data
        }, {
          :secret => @client.secret,
          :method => :http
        })
      end
      
    end
  end
end