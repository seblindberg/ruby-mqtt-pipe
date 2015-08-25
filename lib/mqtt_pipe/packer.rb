module MQTTPipe
  class FormatError < StandardError; end
  class EndOfPacket < StandardError; end
  
  ##
  # The packer module is used to pack/unpack classes that
  # supports it.
  
  module Packer
    extend self
    using Types
        
    ##
    # Packs the arguments acording to their type.
    #
    # An ArgumentError is raised if any given class does
    # not support packing.
    
    def pack *values
      values.map{|value| value.to_packed }.join
    rescue NoMethodError
      raise ArgumentError, 'Unknown input format'
    end
     
    alias_method :[], :pack
    
    
    ##
    # Unpacks a serialized object and returns an array of
    # the original values.
    
    def unpack raw, limit: nil
      raw = StringIO.new raw unless raw.respond_to? :read
      result = []
      
      (limit.nil? ? loop : limit.times).each do
        result << unpack_single(raw)
      end
      
      return result
    rescue EndOfPacket
      return result
    end
    
    ##
    # A simple helper method to read a given number of bytes
    # +from+ IO object and format them +as+ anything 
    # supported by Array#unpack.
    
    def read_packed_bytes n = 1, from:, as: 'C'
      raw = from.read(n)
      raise FormatError if raw.nil? or raw.length != n
      
      raw.unpack(as).first
    end
    
    private
    
    def unpack_single raw
      code = raw.read 1
      raise EndOfPacket if code.nil?
      
      type = code.unpack(?C).first
      Types::Type.lookup(type).from_packed type, raw
    end
  end
end
