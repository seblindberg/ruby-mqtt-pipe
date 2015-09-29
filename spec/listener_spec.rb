require 'mqtt_pipe'

describe MQTTPipe::Listener do
  let(:klass) { MQTTPipe::Listener }
  let(:topic)              { 'test/*/topic/#' }
  let(:topic_pattern)       { %r{^test/([^/]+)/topic/?(.*)$} }
  let(:matching_topic_1)   { 'test/some/topic' }
  let(:matching_topic_2)   { 'test/some/topic/with/more/5' }
  let(:non_matching_topic) { 'test/topic/with/8' }

  describe '#new' do    
    it 'expects a topic and an action block' do
      expect{klass.new}.to raise_error(ArgumentError)
      expect{klass.new topic}.to raise_error(ArgumentError)
      expect{klass.new(topic) {}}.not_to raise_error
    end
  end
  
  context 'Using the listener' do
    before :each do
      @listener = klass.new(topic) {|value, captures = 2| value * captures.to_i }
    end
    
    describe '#topic' do    
      it 'returns the topic' do
        expect(@listener.topic).to eq topic
      end
    end
  
    describe '#pattern' do    
      it 'returns a regular expression mathing the pattern' do
        pattern = @listener.pattern
        
        expect(pattern).to be_a(Regexp)
        expect(pattern).to eq topic_pattern
        expect(pattern === topic).to be true
      end
      
      it 'leaves lopics without wildcards as is' do
        listener = klass.new('test/of') {}
        expect(listener.pattern === 'test/of').to be_truthy
        expect(listener.pattern).to eq %r{^test/of$}
      end
    end
    
    describe '#match' do
      it 'requires one argument' do
        expect{@listener.match}.to raise_error ArgumentError
      end
      
      it 'returns true for a matching topic' do
        expect(@listener.match matching_topic_1).to be_truthy
        expect(@listener.match matching_topic_2).to be_truthy
      end
      
      it 'returns nil for a non matching topic' do
        expect(@listener.match non_matching_topic).to be false
      end
      
      it 'also responds to #===' do
        expect(@listener === matching_topic_1).to be true
        expect(@listener === non_matching_topic).to be false
      end
      
      it 'captures wildcard match groups' do
        m = @listener.match matching_topic_2
        
        expect(m).not_to be false
        expect(m[0]).to eq 'some'
        expect(m[1]).to eq 'with/more/5'
      end
    end
    
    describe '#call' do      
      it 'runs the given callback' do
        expect(@listener.call 42).to eq 84
      end
      
      it 'accepts an optional second argument' do
        expect(@listener.call 12, 3).to eq 12*3
      end
      
      it 'also responds to #run' do
        expect(@listener.run 42).to eq 84
      end
    end
  end
end