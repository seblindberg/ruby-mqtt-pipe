module MQTTPipe
  module Types
    refine Array.singleton_class do
      def packer_code; 0x80; end
      
      def from_packed type, raw
        length = if type == packer_code 
          Packer.read_packed_bytes(1, from: raw) + 31
        else
          type - packer_code
        end
        
        array = Packer.unpack raw, limit: length
        raise FormatError, 'Badly formatted array' unless array.length == length
        
        return array
      end
    end

    refine Array do
      def to_packed
        header = case length
        when 0 then return nil.to_packed
        when 1..31
          [self.class.packer_code + length].pack(?C)
        when 32..288
          [self.class.packer_code, length - 31].pack('C2')
        else
          raise ArgumentError, 'Array is too long'
        end
        
        header + map{|v| v.to_packed }.join
      end
    end
  end
end