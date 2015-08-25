module MQTTPipe
  class Pipe
    class ConnectionError < StandardError; end
    def initialize &block      
      @config = Config.new
      
      @config.instance_eval &block unless block.nil?
    end
    
    def open host, port: 1883, &block
      MQTT::Client.connect host: host, port: port do |client|
  
        # Subscribe
        topics = @config.listeners.map{|listener| listener.topic }
        
        unless topics.empty?
        
          client.subscribe *topics
          
          listener_thread = Thread.new do
            client.get do |topic, data|
              begin
                unpacked_data = Packer.unpack data
              rescue FormatError
                puts 'Could not parse data!'
                next
              end
              @config.listeners.each do |listener|
                if m = listener.match(topic)
                  listener.call unpacked_data, *m.captures
                end
              end
            end
          end
          
        end
        
        if block.nil?
          begin
            listener_thread.join unless topics.empty?
          rescue Interrupt
            puts ' Exiting'
          end
        else
          context = Context.new client
          
          begin
            context.instance_eval &block
          rescue ConnectionError
            puts 'need to reconnect'
          rescue Interrupt
            puts ' Exiting'
          ensure
            listener_thread.exit unless topics.empty?
          end
        end
        
      end
    end
    
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

