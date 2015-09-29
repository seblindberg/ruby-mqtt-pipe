module MQTTPipe
  
  ##
  # Used to store topics along with their actions. 
  # Contains conveniens methods for matching the topic to a
  # given string as well as calling the action.
  
  class Listener
    attr_reader :topic, :pattern, :action
    
    ##
    # The listener requires a topic string and a callable 
    # action to initialize.
    #
    # An ArgumentError is raised if no action is given
    
    def initialize topic, &action
      raise ArgumentError, 'No block given' if action.nil?
      
      @topic = topic
      @action = action
      
      pattern = topic.gsub('*', '([^/]+)').gsub('/#', '/?(.*)').gsub('#', '(.*)')
      @pattern = %r{^#{pattern}$}
    end
    
    ##
    # Check if a given topic string matches the listener 
    # topic.
    #
    # Returns an array containing any matched sections of
    # topic, if there was a match. False otherwise.

    def match topic
      m = @pattern.match topic
      m.nil? ? false : m.captures
    end
    
    ##
    # Returns true if the topic matches listener topic 
    # Otherwise false.
    
    def === topic
      @pattern === topic
    end
    
    ##
    # Call the listener action
    
    def call *args
      #raise ArgumentError, 'No value provided' if args.empty?
      @action.call *args
    end
    
    alias_method :run, :call
  end
end
