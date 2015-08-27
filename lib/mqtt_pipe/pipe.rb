module MQTTPipe
  
  ##
  # The actual wrapper class for MQTT
  
  class Pipe
    
    ##
    # Raised when the connection unexpectedly lost.
    
    class ConnectionError < StandardError; end
    
    
    def initialize &block
      @listeners = []    
      #@config = Config.new  
      
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
      MQTT::Client.connect host: host, port: port do |client|
  
        # Subscribe
        listener_thread = nil
        
        unless @listeners.empty?
          listener_thread = Thread.new do
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
              end
            end
          end
          
          client.subscribe *topics
        end
                  
        unless block.nil?
          context = Context.new client
          
          begin
            context.instance_eval &block
          rescue ConnectionError
            
            puts 'Need to reconnect'
          rescue Interrupt
          ensure
            listener_thread.exit unless topics.empty?
          end
        
        else
          begin
            listener_thread.join unless topics.empty?
          rescue Interrupt
          end
        end
      end
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

