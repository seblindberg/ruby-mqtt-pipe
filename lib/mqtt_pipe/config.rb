module MQTTPipe
  class Config
    attr_reader :listeners
    
    def initialize
      @listeners = []
    end

    def on topic, &action
      raise ArgumentError, 'No block given' if action.nil?
      @listeners << Listener.new(topic, &action)
    end
  end
end
