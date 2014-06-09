require "test_helper"
require "data"

class TestDump < Minitest::Test
  def test_dumping
    TEST_DATA.each do |bin, val|
      assert_equal bin, CBOR.dump(val), "dumping #{val.inspect}"
    end
  end

  class Dummy; end
  def test_dump_invalid
    assert_raises CBOR::CborError do
      CBOR.dump(Dummy.new)
    end
  end

  def test_dump_large_int
    assert_raises CBOR::CborError do
      CBOR.dump(18446744073709551616)
    end
  end

  def test_dumps_symbols
    assert_equal "\x66foobar".b, CBOR.dump(:foobar)
  end
end
