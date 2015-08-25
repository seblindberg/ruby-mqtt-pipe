require 'mqtt_pipe'

describe MQTTPipe::Config do
  let(:klass) { MQTTPipe::Config }
  
  before :each do 
    @config = klass.new
  end
    
  describe '#on' do    
    it 'requires one argument and a block' do
      expect{@config.on}.to raise_error(ArgumentError)
      expect{@config.on 'test'}.to raise_error(ArgumentError)
      expect{@config.on('test') {}}.not_to raise_error
    end
    
    it 'stores the listener' do
      expect(@config.listeners.length).to eq(0)
      
      @config.on('test') {}
      
      expect(@config.listeners.length).to eq(1)
    end
  end


end