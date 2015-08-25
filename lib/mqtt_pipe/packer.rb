module MQTTPipe
  class FormatError < StandardError; end
  class EndOfPacket < StandardError; end
    
  module Packer
    extend self
    using Types
    
    def pack_single value
      value.to_packed
    rescue NoMethodError
      raise ArgumentError, 'Unknown input format'
    end
    
    def pack *values
      values.map{|value| pack_single value }.join
    end
        
    alias_method :[], :pack
    
    def unpack raw
      raw = StringIO.new raw if raw.is_a? String
      result = []
      
      loop do
        result << unpack_single(raw)
      end
    rescue EndOfPacket
      return result
    end
    
    def unpack_single raw
      code = raw.read 1
      raise EndOfPacket if code.nil?
      
      type = code.unpack(?C).first
      Types::Type.lookup(type).from_packed type, raw
    end
    
    def read_packed_bytes n = 1, from:, as: 'C'
      raw = from.read(n)
      raise FormatError if raw.nil? or raw.length != n
      
      raw.unpack(as).first
    end
  end
end
