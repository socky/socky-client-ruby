require 'socky/authenticator'

module Socky
  module Client
    class Request

      def initialize(event, channel, options)
        body = body_from_options(event, channel, options)
        puts body.inspect
      end

      private

      def body_from_options(event, channel, options)
        timestamp = Time.now.to_i
        body = {}
        body['event'] = event
        body['channel'] = channel
        body['timestamp'] = timestamp
        body['data'] = options[:data] || options['data']
        auth = Authenticator.authenticate({
          'event' => event,
          'channel' => channel,
          'connection_id' => timestamp
        }, false, Client.secret)
        body['auth'] = auth['auth']
        body
      end

    end
  end
end