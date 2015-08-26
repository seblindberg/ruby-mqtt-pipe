module MQTTPipe
  
  ##
  # An instance of Config is used as the context in which
  # the pipe is configured.
  
  class Config
    attr_reader :listeners
    
    def initialize
      @listeners = []
    end

    ##
    # Subscribe to a topic and attatch an action that will
    # be called once a message with a matching topic is 
    # received.

    def on topic, &action
      raise ArgumentError, 'No block given' if action.nil?
      @listeners << Listener.new(topic, &action)
    end
    
    ##
    # Subscribe to all topics
    
    def on_anything &action
      on '#', &action
    end
  end
end
