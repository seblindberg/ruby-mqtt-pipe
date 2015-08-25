require 'mqtt'

require 'mqtt_pipe/version'
require 'mqtt_pipe/types'
require 'mqtt_pipe/packer'
require 'mqtt_pipe/config'
require 'mqtt_pipe/listener'
require 'mqtt_pipe/pipe'

module MQTTPipe
  extend self

  def create &block
    Pipe.new &block
  end
end
