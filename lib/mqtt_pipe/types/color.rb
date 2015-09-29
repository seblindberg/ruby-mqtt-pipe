module MQTTPipe
  module Types
    class Color
      PACKER_CODE = 0xC9
      
      attr_reader :r, :g, :b
      
      def initialize r, g, b
        @r, @g, @b = r, g, b
      end
      
      def to_packed
        [PACKER_CODE, r, g, b].pack 'C4'
      end
    end
    
    class << Color
      def from_packed _, raw
        color = 3.times.map do
          Packer.read_packed_bytes(1, from: raw, as: 'C')
        end
        new *color
      end
    end
  end
end