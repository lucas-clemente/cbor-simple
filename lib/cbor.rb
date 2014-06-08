require "bigdecimal"

require "cbor/version"
require "cbor/consts"
require "cbor/error"
require "cbor/dumper"

module CBOR
  def self.dump(val)
    Dumper.new.dump(val)
  end

  def self.register_class(klass, tag, &block)
    Dumper.register_class(klass, tag, &block)
  end
end

CBOR.register_class Time, CBOR::Consts::Tag::DATETIME do |val|
  dump(val.iso8601(6))
end

CBOR.register_class BigDecimal, CBOR::Consts::Tag::DECIMAL do |val|
  sign, significant_digits, base, exponent = val.split
  raise CBOR::CborError.new("NaN while sending BigDecimal #{val.inspect}") if sign == 0
  val = sign * significant_digits.to_i(base)
  dump([exponent - significant_digits.size, val])
end
