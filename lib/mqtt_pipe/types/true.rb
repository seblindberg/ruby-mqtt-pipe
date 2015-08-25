module MQTTPipe
  module Types
    refine TrueClass.singleton_class do
      def packer_code; 0xC2; end
      
      def from_packed type, _
        type == packer_code ? false : true
      end
    end

    refine TrueClass do
      def to_packed
        [self.class.packer_code + 1].pack ?C
      end
    end
  end
end