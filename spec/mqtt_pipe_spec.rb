require 'mqtt_pipe'

describe MQTTPipe do
  describe '#create' do
    it 'returns a pipe' do
      expect(MQTTPipe.create).to be_a MQTTPipe::Pipe
    end
  end
end