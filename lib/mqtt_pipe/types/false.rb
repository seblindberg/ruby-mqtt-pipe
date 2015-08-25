module MQTTPipe
  module Types
    refine FalseClass.singleton_class do
      def packer_code; 0xC2; end
      
      def from_packed type, _
        type == packer_code ? false : true
      end
    end

    refine FalseClass do
      def to_packed
        [self.class.packer_code].pack ?C
      end
    end
  end
end