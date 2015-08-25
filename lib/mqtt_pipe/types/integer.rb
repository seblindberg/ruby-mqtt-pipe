module MQTTPipe
  module Types
    refine Integer.singleton_class do
      def packer_code; 0xC4; end
      
      def from_packed type, raw
        case type
        when 0xC4
          Packer.read_packed_bytes 1, from: raw
        when 0xC5
          Packer.read_packed_bytes 2, from: raw, as: 's<'
        when 0xC6
          Packer.read_packed_bytes 4, from: raw, as: 'l<'  
        when 0..0x7F, 0xD0..0xFF
          [type].pack('C').unpack('c').first
        end
      end
    end
    
    refine Integer do
      def to_packed
        case self
        when -48..127
          [self].pack ?C
        when 0..255
          [self.class.packer_code, self].pack 'C2'
        when -32_768..32_767
          [self.class.packer_code + 1, self].pack 'Cs<'
        when -2_147_483_648..2_147_483_647
          [self.class.packer_code + 2, self].pack 'Cl<'
        else
          raise ArgumentError, 'Integer is larger than 32 bit signed'
        end
      end
      
      
    end
  end
end