module MQTTPipe
  module Types
    refine Float.singleton_class do
      def packer_code; 0xC7; end
      
      def from_packed _, raw
        Packer.read_packed_bytes 4, from: raw, as: 'e'
      end
    end

    refine Float do
      def to_packed
        [self.class.packer_code, self].pack 'Ce'
      end
    end
  end
end