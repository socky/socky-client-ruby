Socky - client in Ruby
===========

Socky is push server for Ruby based on WebSockets. It allows you to break border between your application and client browser by letting the server initialize a connection and push data to the client.

## Example

You can try [live example](http://sockydemo.imanel.org) or view its [source code](http://github.com/socky/socky-example)

Also important information can be found on our [google group](http://groups.google.com/group/socky-users).

## Install

The best way to install Socky client is via RubyGems:

    gem install socky-client
    irb
    require 'socky-client'

Socky ruby client requires the json gem. It is automatically installed by the gem install command.

Alternative method is to clone repo and use it directly:

    git clone git://github.com/socky/socky-client-ruby.git
    cd socky-client-ruby
    irb
    require 'lib/socky-client'

You can also build it after clonning(this will require Jeweler gem)

    rake gemspec
    rake build

## Usage

### Socky.send method

Socky client offers method to send data to WebSocket server. Easiest way to show that will be example:

    Socky.send "alert('ok!');"

This will send alert to all connected and authorized users.

Send method offers 2 methods of filtering - by users and channels.

#### Filtering by users

Socky.send can be used with :user or :users option. You can provide list of users to which message will be sent. It can be 1 string or array of strings - both keywords works exactly the same. Example:

    Socky.send "alert('ok!');", :users => ["user1", "user2"]

This will send message to all users with "user" set to "user1" or "user2" and nobody else.

#### Filtering by channels.

This works exactly the same as filtering by users. Keywords are :channel and :channels. Message will be received if user have at last one of channels on channel list.

    Socky.send "alert('ok!');", :channels => "channel1"

This will be received both by users with channels ["channel1"] and channels ["channel1", "channel2"] but will not be received by user with empty channel list or ["channel2"]

#### Merging both filters

You can use both filters at the some time. In this case only users with both "users" and "channels" requirement will receive message.

    Socky.send "alert('ok!');", :users => ["user1", "user2"], :channels => "channel1"

This will be received by user with "user1" and ["channel1", "channel2"] but not by "user2" and ["channel2"]

### Other methods

Additionaly you have method to show all connected users:

    Socky.show_connections

## Configuration

Configuration file is located in application directory:

    socky_hosts.yml

In this file you should have array of hosts together with configuration of each.

Default configuration should like something like that:

    :hosts:
      - :host: 127.0.0.1
        :port: 8080
        :secret: my_secret_key
        :secure: false

### Configuration Settings

| *Setting* | *Value format* | *Description*                        |
| --------- | -------------- | ------------------------------------ |
| `:host`   | `[string]`     | IP or host where socky server exists
| `:port`   | `[integer]`    | Port on with socky server listens
| `:secret` | `[string]`     | Key that will be provided to authenticate to this server(must match secret key in server configuration
| `:secure` | `[boolean]`    | Set wss/SSL mode for that host

## License

(The MIT License)

Copyright (c) 2010 Bernard Potocki

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.