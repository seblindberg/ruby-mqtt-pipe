module MQTTPipe
  module Types
    refine Time.singleton_class do
      def packer_code; 0xC8; end
      
      def from_packed _, raw
        at(Packer.read_packed_bytes 4, from: raw, as: 'L<')
      end
    end

    refine Time do
      def to_packed
        [self.class.packer_code, to_i].pack 'CL<'
      end
    end
  end
end