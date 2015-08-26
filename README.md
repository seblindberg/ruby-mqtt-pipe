# MqttPipe

This gem wraps the MQTT gem and adds a serializer for simple data structures.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mqtt_pipe'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mqtt_pipe

## Usage

```ruby
pipe = MQTTPipe.create do
  on 'hello/world/#' do |message, id|
    p message, id
  end
end

pipe.open 'test.mosquitto.org', port: 1883 do
  100.times do |i|
    send "hello/world/#{i}", Time.now
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mqtt_pipe/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
