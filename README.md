# Socky - client in Ruby [![](https://travis-ci.org/socky/socky-client-ruby.png)](http://travis-ci.org/socky/socky-client-ruby)

Also important information can be found on our [google group](http://groups.google.com/group/socky-users).

## Installation

``` bash
$ gem install socky-client --pre
```

## Usage

First require Socky Client:

``` ruby
require 'socky/client'
```

Then createn new Client instance. Parameters required are full address of Socky Server(including app name) and secret of app.

``` ruby
$socky_client = Socky::Client.new('http://ws.socky.org:3000/http/test_app', 'my_secret')
```

Please note that Ruby Client is HTTP client(not WebSocket) so you need to user http protocol(instead of 'ws') and 'http' namespace(instead of 'websocket'). If you receive EOFError then you probably should double-check address ;)

This instance of Socky Client can trigger events for all users of server. To do so you can use one of methods:

``` ruby
$socky_client.trigger!('my_event', :channel => 'my_channel', :data => 'my data') # Will raise on error
$socky_client.trigger('my_event', :channel => 'my_channel', :data => 'my data') # Will return false on error
$socky_client.trigger_async('my_event', :channel => 'my_channel', :data => 'my data') # Async method
```

## License

(The MIT License)

Copyright (c) 2010 Bernard Potocki

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.