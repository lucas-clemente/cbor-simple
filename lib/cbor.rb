require "bigdecimal"
require "stringio"

require "cbor/version"
require "cbor/consts"
require "cbor/error"
require "cbor/dumper"
require "cbor/loader"

module CBOR
  def self.dump(val)
    Dumper.new.dump(val)
  end

  # Load CBOR-encoded data.
  #
  # `binary` can be either a String or an IO object. In both cases the first
  # encoded object will be returned.
  #
  # Local tags (as a hash of tag => lambda) will only be valid within this method.
  def self.load(binary, local_tags = {})
    if binary.is_a? String
      binary = StringIO.new(binary)
    elsif !binary.respond_to? :read
      raise CborError.new("can only load from String or IO")
    end
    Loader.new(binary, local_tags).load
  end

  def self.register_class(klass, tag, &block)
    Dumper.register_class(klass, tag, &block)
  end

  def self.register_tag(tag, &block)
    Loader.register_tag(tag, &block)
  end
end

CBOR.register_class Time, CBOR::Consts::Tag::DATETIME do |val|
  val.iso8601(6)
end

CBOR.register_tag CBOR::Consts::Tag::DATETIME do |raw|
  Time.iso8601(raw)
end

CBOR.register_class BigDecimal, CBOR::Consts::Tag::DECIMAL do |val|
  sign, significant_digits, base, exponent = val.split
  raise CBOR::CborError.new("NaN while sending BigDecimal #{val.inspect}") if sign == 0
  val = sign * significant_digits.to_i(base)
  [exponent - significant_digits.size, val]
end

CBOR.register_tag CBOR::Consts::Tag::DECIMAL do |raw|
  arr = raw
  raise CBOR::CborError.new("invalid decimal") if arr.length != 2
  BigDecimal.new(arr[1]) * (BigDecimal.new(10) ** arr[0])
end

if defined? UUIDTools::UUID
  CBOR.register_class UUIDTools::UUID, CBOR::Consts::Tag::UUID do |val|
    val.raw.b
  end

  CBOR.register_tag CBOR::Consts::Tag::UUID do |raw|
    UUIDTools::UUID.parse_raw(raw)
  end
end
