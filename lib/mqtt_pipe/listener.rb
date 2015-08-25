module MQTTPipe
  class Listener
    attr_reader :topic, :pattern
    
    def initialize topic, &action
      raise ArgumentError, 'No block given' if action.nil?
      
      @topic = topic
      @action = action
      
      pattern = topic.gsub('*', '([^/]+)').gsub('/#', '/?(.*)')
      @pattern = %r{^#{pattern}$}
    end

    def match topic
      @pattern.match topic
    end
    
    def === topic
      @pattern === topic
    end
    
    def call *args
      #raise ArgumentError, 'No value provided' if args.empty?
      @action.call *args
    end
    
    alias_method :run, :call
  end
end
