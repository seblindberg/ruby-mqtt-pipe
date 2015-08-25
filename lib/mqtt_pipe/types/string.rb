module MQTTPipe
  module Types
    refine String.singleton_class do
      def packer_code; 0xA0; end
      
      def from_packed type, raw
        length = if type == packer_code
          Packer.read_packed_bytes(1, from: raw) + 31
        else
          type - packer_code
        end
        Packer.read_packed_bytes length, from: raw, as: 'A*'
      end
    end
    
    refine String do
      def to_packed
        case length
        when 0 then return nil.to_packed
        when 1..31
          [self.class.packer_code + length, self].pack('CA*')
        when 32..288
          [self.class.packer_code, length - 31, self].pack('C2A*')
        else
          raise ArgumentError, 'String is too long'
        end
      end
    end
  end
end