module MQTTPipe
  module Types
    module Type
      extend self
      
      def packer_code
        0xC0
      end

      def to_packed
        [packer_code, packer_code].pack 'C2'
      end
      
      def lookup type
        case type
        when 0x80..0x9F then Array
        when 0xA0..0xBF then String
        when 0xC0       then Type          
        when 0xC1       then NilClass
        when 0xC2       then FalseClass
        when 0xC3       then TrueClass
        when 0xC7       then Float
        when 0xC8       then Time
        when 0xC9       then Color
        when 0x00..0x7F,
             0xD0..0xFF,
             0xC4..0xC6 then Integer
        end
      end
      
      def from_packed _, raw
        lookup(Packer.read_packed_bytes 1, from: raw)
      end
    end
  end
end