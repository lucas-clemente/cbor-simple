class CBOR::Dumper
  include CBOR::Consts

  @@registered_classes = {}

  def self.register_class(klass, tag, &block)
    @@registered_classes[klass] = {
      tag: tag,
      block: block
    }
  end

  def dump(val)
    case val
    when nil
      dump_simple(Simple::NULL)
    when TrueClass
      dump_simple(Simple::TRUE)
    when FalseClass
      dump_simple(Simple::FALSE)
    when Fixnum, Bignum
      if val < 0
        dump_uint(Major::NEGINT, -val-1)
      else
        dump_uint(Major::UINT, val)
      end
    when Float
      dump_simple(Simple::FLOAT64) + [val].pack("G")
    when String, Symbol
      s = val.to_s.dup.force_encoding(Encoding::UTF_8)
      dump_uint(s.valid_encoding? ? Major::TEXTSTRING : Major::BYTESTRING, s.bytesize) + s.b
    when Array
      dump_uint(Major::ARRAY, val.count) + val.map{|e| dump(e)}.join
    when Hash
      dump_uint(Major::MAP, val.count) + val.map{|k, v| dump(k.to_s) + dump(v)}.join
    else
      if h = @@registered_classes[val.class]
        dump_uint(Major::TAG, h[:tag]) + dump(h[:block].call(val))
      else
        raise CBOR::CborError.new("dumping not supported for objects of type #{val.class} (#{val.inspect})")
      end
    end
  end

  private

  def dump_uint(major, val)
    typeInt = (major << 5);
    if val <= 23
      [typeInt | val].pack("C")
    elsif val < 0x100
      [typeInt | 24, val].pack("CC")
    elsif val < 0x10000
      [typeInt | 25, val].pack("CS>")
    elsif val < 0x100000000
      [typeInt | 26, val].pack("CL>")
    elsif val < 0x10000000000000000
      [typeInt | 27, val].pack("CQ>")
    else
      raise CBOR::CborError.new("this cbor implementation only supports integers up to 64bit")
    end
  end

  def dump_simple(val)
    [(Major::SIMPLE << 5) | val].pack("C")
  end
end
