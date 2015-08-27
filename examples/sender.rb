require 'mqtt_pipe'

pipe = MQTTPipe.create

pipe.on 'hello/world/5' do
  puts 'received 5'
end

pipe.open 'test.mosquitto.org', port: 1883 do
  counter = 0
  loop do
    send 'hello/world/' + counter.to_s, Time.now
    puts 'sending...'
    counter += 1
    sleep 1
  end
end