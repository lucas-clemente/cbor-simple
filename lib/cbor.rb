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
  # `binary` can be either a String or an IO object. In both cases the first
  # encoded object will be returned.
  def self.load(binary)
    if binary.is_a? String
      binary = StringIO.new(binary)
    elsif !binary.is_a? IO
      raise CborError.new("can only load from String or IO")
    end
    Loader.new(binary).load
  end

  def self.register_class(klass, tag, &block)
    Dumper.register_class(klass, tag, &block)
  end

  def self.register_tag(tag, &block)
    Loader.register_tag(tag, &block)
  end
end

CBOR.register_class Time, CBOR::Consts::Tag::DATETIME do |val|
  dump(val.iso8601(6))
end

CBOR.register_tag CBOR::Consts::Tag::DATETIME do
  Time.iso8601(load)
end

CBOR.register_class BigDecimal, CBOR::Consts::Tag::DECIMAL do |val|
  sign, significant_digits, base, exponent = val.split
  raise CBOR::CborError.new("NaN while sending BigDecimal #{val.inspect}") if sign == 0
  val = sign * significant_digits.to_i(base)
  dump([exponent - significant_digits.size, val])
end

CBOR.register_tag CBOR::Consts::Tag::DECIMAL do
  arr = load
  raise CBOR::CborError.new("invalid decimal") if arr.length != 2
  BigDecimal.new(arr[1]) * (BigDecimal.new(10) ** arr[0])
end
