module CBOR::Consts
  module Major
    UINT = 0
    NEGINT = 1
    BYTESTRING = 2
    TEXTSTRING = 3
    ARRAY = 4
    MAP = 5
    TAG = 6
    SIMPLE = 7
  end

  module Tag
    DATETIME = 0
    DECIMAL = 4
    UUID = 37
  end

  module Simple
    FALSE = 20
    TRUE = 21
    NULL = 22
    FLOAT16 = 25
    FLOAT32 = 26
    FLOAT64 = 27
  end
end
