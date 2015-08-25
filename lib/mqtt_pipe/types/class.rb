module MQTTPipe
  module Types    
    refine Class do
      def to_packed
        [Type.packer_code, self.packer_code].pack 'C2'
      end 
    end
  end
end