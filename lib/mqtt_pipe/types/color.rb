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
  end
end