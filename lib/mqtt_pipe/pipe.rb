module MQTTPipe
  
  ##
  # The actual wrapper class for MQTT
  
  class Pipe
    
    ##
    # Raised when the connection unexpectedly lost.
    
    class ConnectionError < StandardError; end
    
    ##
    # Create a new pipe and optionally yield to a block
    
    def initialize &block
      @listeners = []      
      instance_eval &block unless block.nil?
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
    
    alias_method :on_everything, :on_anything
    
    def topics
      @listeners.map{|listener| listener.topic }
    end
    
    ##
    # Open the pipe
    
    def open host, port: 1883, &block
      listener_thread = nil
      client = MQTT::Client.connect host: host, port: port
  
      unless @listeners.empty?
        listener_thread = Thread.new(Thread.current) do |parent|          
          client.get do |topic, data|
            begin
              unpacked_data = Packer.unpack data
              
              @listeners.each do |listener|
                if m = listener.match(topic)
                  listener.call unpacked_data, *m
                end
              end
              
            rescue Packer::FormatError
              # TODO: Handle more gracefully
              puts 'Could not parse data!'
              next
              
            # Raise the exception in the parent thread 
            rescue Exception => e
              parent.raise e
            end
          end
        end
        
        client.subscribe *topics
      end
      
      # Call user block
      unless block.nil?
        begin
          context = Context.new client
          context.instance_eval &block
        rescue ConnectionError
          puts 'TODO: Handle reconnect'
        rescue Interrupt
          exit
        end
      end
      
      # Join with listener thread
      begin
        listener_thread.join unless listener_thread.nil?
      rescue Interrupt
      end
      
    ensure
      client.disconnect
      listener_thread.exit unless listener_thread.nil?
    end
    
    private
    
    class Context
      def initialize client
        @client = client
      end
      
      def send topic, *data
        raise ConnectionError unless @client.connected?
        @client.publish topic, Packer.pack(*data)
      end
    end
  end
end

