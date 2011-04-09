module Socky
  module Client
    ROOT = File.expand_path(File.dirname(__FILE__))

    autoload :Request, "#{ROOT}/client/request"

    class << self
      attr_accessor :host, :secret

      def trigger(event, options = {})
        channel = options.delete(:channel) || options.delete('channel')
        raise 'no channel provided' if channel.nil?
        Request.new(event, channel, options)
      end

    end
  end
end
