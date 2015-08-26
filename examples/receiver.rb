require 'mqtt_pipe'

pipe = MQTTPipe.create do
  on 'hello/world/#' do |message, id|
    p message, id
  end
end

pipe.open 'test.mosquitto.org', port: 1883