require 'mqtt_pipe'

describe MQTTPipe::Pipe do
  let(:klass) { MQTTPipe::Pipe }
  
  describe '#new' do
    it 'accepts a block that evaluates within the context of the pipe' do
      tester = self
      pipe_inside = nil
      pipe_outside = MQTTPipe::Pipe.new do
        tester.expect(self).to tester.be_a tester.klass       
        pipe_inside = self
      end
      
      expect(pipe_inside).to be pipe_outside
    end
  end
  
  context 'using a pipe' do
    before :each do 
      @pipe = klass.new
    end
    
    describe '#on' do
      it 'requires one argument and a block' do
        expect{@pipe.on}.to raise_error ArgumentError
        expect{@pipe.on 'test'}.to raise_error ArgumentError
        expect{@pipe.on('test') {}}.not_to raise_error
      end
    end
    
    describe '#on_anything' do
      it 'does not accept a topic' do
        expect{@pipe.on_anything('test') {}}.to raise_error ArgumentError
      end
    end
    
    describe '#topics' do
      it 'stores the topics that have beed subscribed to' do
        expect(@pipe.topics.empty?).to be true
        
        @pipe.on('test/1') {}
        
        expect(@pipe.topics.length).to be 1
        expect(@pipe.topics.first).to eq 'test/1'
        
        @pipe.on_anything {}
        
        expect(@pipe.topics.length).to be 2
        expect(@pipe.topics.last).to eq '#'
      end
    end
  end
end