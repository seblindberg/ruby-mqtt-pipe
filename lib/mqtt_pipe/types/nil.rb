module MQTTPipe
  module Types
    refine NilClass.singleton_class do
      def packer_code; 0xC1; end
      
      def from_packed _, _
        return nil
      end
    end
    
    refine NilClass do
      def to_packed
        [self.class.packer_code].pack ?C
      end
    end
  end
end