# MQTTPipe

This gem wraps the [MQTT gem](https://github.com/njh/ruby-mqtt) and adds a serializer for simple data structures. The serializer is heavily inspired by [MessagePack](http://msgpack.org) and borrows some of their byte values when packing the data. It is however much more restricted in what data types it supports. Right now hashes are for example not supported, but this may change in the future. 

The reason for the limitations is that the gem is later meant to talk to devices with much more limited hardware (think Arduino, but really the ESP8266).

## TODO

1. Handle disconnects gracefully
2. Possibly add a few data types. See below for more details on that.

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
MQTTPipe.create do
  on 'hello/world/#' do |message, id|
    p message, id
  end
  
  open 'test.mosquitto.org', port: 1883 do
    100.times do |i|
      send "hello/world/#{i}", Time.now
    end
  end
end
```

Everything does not need to be contained in a block:

```ruby
pipe = MQTTPipe.create

pipe.on 'hello/#' do
  # do something
end

pipe.open 'test.mosquitto.org', port: 1883 do
  100.times do |i|
    send "hello/world/#{i}", Time.now
  end
end
```

## Protocol

Taking inspiration from the excellent [MessagePack](http://msgpack.org) project each data type is represented by a byte value, or in same cases a range of values. The currently supported data types along with their byte values are:

Data type                 | Byte value (in hex)
------------------------- | -------------------
`0..127`                  | 0x00 - 0x7F
`Array`                   | 0x80 - 0x9F
`String`                  | 0xA0 - 0xBF
`Class`                   | 0xC0
`NilClass`                | 0xC1
`FalseClass`              | 0xC2
`TrueClass`               | 0xC3
`8 bit unsigned`          | 0xC4
`6 bit signed`            | 0xC5
`32 bit signed`           | 0xC6
`Float`                   | 0xC7
`Time`                    | 0xC8
`MQTTPipe::Types::Color`  | 0xC9
-                         | 0xCA
-                         | 0xCB
-                         | 0xCC
-                         | 0xCD
-                         | 0xCE
-                         | 0xCF
`-48..-1`                 | 0xD0 - 0xFF

Note that the integers are split over several codes to accommodate for the various sizes that can occur. Because it is common to send small numerical values these can in most cases be represented by a single byte, instead of two.

Array and string are also special cases in that their sizes are not known. They require a length value to be passed along with them, but instead of always including an extra byte for that purpose, length smaller than 32 can be encoded directly in the type byte value. An example is shown below:

#### Strings with length 1..31:

    'test' -> [0xA0 + 4, 0x74, 0x65, 0x73, 0x74]

#### Strings with length 32..288
    
    'testing how really long strings are encoded'
           -> [0xA0, 43 - 32, 0x74, 0x65, 0x73, ...]

Some data types that may be supported in the future are:

  - IP Addresses
  - Hashes
  - Strings longer than 288 characters
  - UTF-8 encoded strings (could be a breaking change)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mqtt_pipe/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
