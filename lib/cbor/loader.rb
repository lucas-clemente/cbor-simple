class CBOR::Loader
  include CBOR::Consts

  @@registered_tags = {}

  def self.register_tag(tag, &block)
    @@registered_tags[tag] = block
  end

  def initialize(io, local_tags)
    @io = io
    @local_tags = local_tags
  end

  def load
    typeInt = get_bytes(1, "C")
    major = (typeInt >> 5)

    case major
    when Major::UINT
      get_uint(typeInt)
    when Major::NEGINT
      -get_uint(typeInt)-1
    when Major::BYTESTRING
      count = get_uint(typeInt)
      get_bytes(count, "a*")
    when Major::TEXTSTRING
      count = get_uint(typeInt)
      s = get_bytes(count, "a*").force_encoding(Encoding::UTF_8)
      unless s.valid_encoding?
        raise CBOR::CborError.new("Received non-utf8 string when expecting utf8")
      end
      s
    when Major::ARRAY
      count = get_uint(typeInt)
      count.times.map { load }
    when Major::MAP
      count = get_uint(typeInt)
      Hash[count.times.map { [load, load] }]
    when Major::TAG
      tag = get_uint(typeInt)
      if block = @@registered_tags[tag]
        instance_exec(&block)
      elsif block = @local_tags[tag]
        instance_exec(&block)
      else
        raise CBOR::CborError.new("Unknown tag #{tag}")
      end
    when Major::SIMPLE
      case typeInt & 0x1F
      when Simple::FALSE
        false
      when Simple::TRUE
        true
      when Simple::NULL
        nil
      when Simple::FLOAT32
        get_bytes(4, "g")
      when Simple::FLOAT64
        get_bytes(8, "G")
      else
        raise CBOR::CborError.new("Unknown simple type #{simple}")
      end
    else
      raise CBOR::CborError.new("Unknown major type #{major}")
    end
  end

  private

  def get_uint(typeInt)
    smallLen = typeInt & 0x1F
    case smallLen
    when 24
      get_bytes(1, "C")
    when 25
      get_bytes(2, "S>")
    when 26
      get_bytes(4, "L>")
    when 27
      get_bytes(8, "Q>")
    else
      smallLen
    end
  end

  def get_bytes(count, pack_opts)
    s = @io.read(count)
    if s.size < count
      raise CBOR::CborError.new("Unexpected end of input")
    end
    s.unpack(pack_opts).first
  end
end
