require 'mqtt_pipe'

describe MQTTPipe::Packer do
  let(:klass) { MQTTPipe::Packer }
  
  describe '#pack/#[]' do
    describe 'Array' do
      it 'serializes empty arrays to nil' do
        expect(klass[[]]).to eq [0xC1].pack('C')
      end
      
      it 'serializes short arrays' do
        arr = (0..4).to_a
        expect(klass[arr]).to eq [0x85, 0, 1, 2, 3, 4].pack('C*')
      end
      
      it 'serializes long arrays' do
        arr = (1..100).to_a
        expect(klass[arr].length).to be 102
      end
    end
    
    describe 'String' do
      it 'serializes empty strings to nil' do
        expect(klass['']).to eq [0xC1].pack('C')
      end
      
      it 'serializes short strings' do
        expect{klass['string']}.not_to raise_error
        expect(klass['string']).to eq [0xA6, 'string'].pack('CA*')
      end
      
      it 'serializes long strings' do
        long_string = '*' * 33
        expect(klass[long_string]).to eq [0xA0, long_string.length - 31, long_string].pack('C2A*')
      end
      
      it 'does not serialize string longer than 288 chars' do
        too_long_string = '*' * 289
        expect{klass[too_long_string]}.to raise_error ArgumentError
      end
    end
    
    describe 'Type' do
      it 'serializes classes' do
        expect(klass[MQTTPipe::Types::Type]).to eq [0xC0, 0xC0].pack('C2')
        
        expect(klass[NilClass]).to eq [0xC0, 0xC1].pack('C2')
        
        expect(klass[FalseClass]).to eq [0xC0, 0xC2].pack('C2')
        expect(klass[TrueClass]).to eq [0xC0, 0xC2].pack('C2')
        
        expect(klass[Array]).to eq [0xC0, 0x80].pack('C2')
        expect(klass[String]).to eq [0xC0, 0xA0].pack('C2')
        
        expect(klass[Fixnum]).to eq [0xC0, 0xC4].pack('C2')
        expect(klass[Integer]).to eq [0xC0, 0xC4].pack('C2')
        
        expect(klass[Float]).to eq [0xC0, 0xC7].pack('C2')
        expect(klass[Time]).to eq [0xC0, 0xC8].pack('C2')
      end
    end
    
    describe 'Nil' do
      it 'serializes nil values' do
        expect(klass[nil]).to eq [0xC1].pack(?C)
      end
    end
    
    describe 'Boolean' do
      it 'serializes false values' do
        expect(klass[false]).to eq [0xC2].pack(?C)
      end
      
      it 'serializes true values' do
        expect(klass[true]).to eq [0xC3].pack(?C)
      end
    end
    
    describe 'Integer' do
      it 'serializes small integers' do
        expect(klass[4]).to eq [4].pack(?c)
        expect(klass[127]).to eq [127].pack(?c)
        expect(klass[-48]).to eq [-48].pack(?c)
      end
      
      it 'serializes bytes' do
        expect(klass[128]).to eq [0xC4, 128].pack('C2')
        expect(klass[255]).to eq [0xC4, 255].pack('C2')
      end
      
      it 'serializes short integers' do
        expect(klass[32_767]).to eq [0xC5, 32_767].pack('Cs<')
        expect(klass[-32_768]).to eq [0xC5, -32_768].pack('Cs<')
      end
      
      it 'serializes integers' do
        expect(klass[2_147_483_647]).to eq [0xC6, 2_147_483_647].pack('Cl<')
        expect(klass[-2_147_483_648]).to eq [0xC6, -2_147_483_648].pack('Cl<')
      end
      
      it 'does not serialize integers larger than 32 bit' do
        expect{klass[2_147_483_648]}.to raise_error ArgumentError
        expect{klass[-2_147_483_649]}.to raise_error ArgumentError
      end
    end
    
    describe 'Float' do
      it 'serializes 32 bit floats' do
        expect(klass[0.2]).to eq [0xC7, 0.2].pack('Ce')
      end
    end
    
    describe 'Time' do
      it 'serializes time' do
        timestamp = Time.now
        expect(klass[timestamp]).to eq [0xC8, timestamp.to_i].pack('CL<')
      end
    end
  end
  
  
  describe '#unpack' do
    it 'raises an error on malformated packets' do
      # Make the list one item longer than what is written
      raw = [0x87, *(1..6).to_a].pack 'CC*'
      expect{klass.unpack(raw)}.to raise_error MQTTPipe::Packer::FormatError
      
      # Strings
      raw = [0xA7, 'string'].pack 'CA*'
      expect{klass.unpack(raw)}.to raise_error MQTTPipe::Packer::FormatError
      
      # Integers
      raw = [0xC4].pack 'C'
      expect{klass.unpack(raw)}.to raise_error MQTTPipe::Packer::FormatError
      
      raw = [0xC5, 1].pack 'C*'
      expect{klass.unpack(raw)}.to raise_error MQTTPipe::Packer::FormatError
      
      raw = [0xC6, 1,2,3].pack 'C*'
      expect{klass.unpack(raw)}.to raise_error MQTTPipe::Packer::FormatError
      
      # Float
      raw = [0xC7].pack 'C*'
      expect{klass.unpack(raw)}.to raise_error MQTTPipe::Packer::FormatError
      
      # Time
      raw = [0xC8, 1].pack 'C*'
      expect{klass.unpack(raw)}.to raise_error MQTTPipe::Packer::FormatError
    end
    
    describe 'Array' do
      it 'deserializes short arrays' do
        raw = [0x86, *(1..6).to_a].pack 'CC6'
        expect(klass.unpack(raw).first).to eq (1..6).to_a
      end
    end
    
    describe 'String' do      
      it 'deserializes short strings' do
        raw = [0xA6, 'string'].pack 'CA*'
        
        expect(klass.unpack(raw).first).to eq 'string'
      end
      
      it 'deserializes long strings' do
        long_string = '*' * 33
        raw = [0xA0, long_string.length - 31, long_string].pack 'C2A*'
        
        expect(klass.unpack(raw).first).to eq long_string
      end
    end
    
    describe 'Type' do
      it 'deserializes types' do
        raw = [0xC0, 0xC0].pack 'C2'
        expect(klass.unpack(raw).first).to be MQTTPipe::Types::Type
      end
    end
    
    describe 'Nil' do      
      it 'deserializes nil' do
        raw = [0xC1].pack 'C'
        expect(klass.unpack(raw).first).to be nil
      end
    end
    
    describe 'Boolean' do      
      it 'deserializes to false' do
        raw = [0xC2].pack 'C'
        expect(klass.unpack(raw).first).to be false
      end
      
      it 'deserializes to true' do
        raw = [0xC3].pack 'C'
        expect(klass.unpack(raw).first).to be true
      end
    end
    
    describe 'Integer' do
      it 'deserializes tiny integers' do
        raw = [127].pack ?C
        expect(klass.unpack(raw).first).to eq 127
        
        raw = [-48].pack ?C
        expect(klass.unpack(raw).first).to eq -48
      end
      
      it 'deserializes bytes' do
        raw = [0xC4, 128].pack 'C2'
        expect(klass.unpack(raw).first).to eq 128
      end
      
      it 'deserializes short integers' do
        raw = [0xC5, 32_767].pack 'Cs<'
        expect(klass.unpack(raw).first).to eq 32_767
        
        raw = [0xC5, -32_768].pack 'Cs<'
        expect(klass.unpack(raw).first).to eq -32_768
      end
      
      it 'deserializes long integers' do
        raw = [0xC6, 2_147_483_647].pack 'Cl<'
        expect(klass.unpack(raw).first).to eq 2_147_483_647
        
        raw = [0xC6, -2_147_483_648].pack 'Cl<'
        expect(klass.unpack(raw).first).to eq -2_147_483_648
      end
    end
    
    describe 'Float' do      
      it 'deserializes float' do
        raw = [0xC7, 0.4].pack 'Ce'
        expect(klass.unpack(raw).first).to be_within(0.0001).of(0.4)
      end
    end
    
    describe 'Time' do
      it 'deserializes time' do
        t = Time.now
        raw = [0xC8, t.to_i].pack 'CL<'
        expect(klass.unpack(raw).first).to be_a Time
        expect(klass.unpack(raw).first - t).to be_within(1).of(0)
      end
    end
  end
  
  describe 'End to end' do
    it 'can serialize and deserialize an object' do
      packet = ['Hello there!', 42, 42_531, ['hi', Time], true, []]
      
      req = klass.pack *packet
      res = klass.unpack req
            
      expect(res[0]).to eq 'Hello there!'
      expect(res[1]).to eq 42
      expect(res[2]).to eq 42_531
      expect(res[3][0]).to eq 'hi'
      expect(res[3][1]).to eq Time
      expect(res[4]).to eq true
      expect(res[5]).to eq nil
    end
  end
end