require "test_helper"

class TestDump < Minitest::Test
  class Dummy; end

  def test_dump_invalid
    assert_raises CBOR::CborError do
      CBOR.dump(Dummy.new)
    end
  end

  def test_dump_null
    assert_equal "\xf6".b, CBOR.dump(nil)
  end

  def test_dump_bools
    assert_equal "\xf5".b, CBOR.dump(true)
    assert_equal "\xf4".b, CBOR.dump(false)
  end

  def test_dump_uints
    assert_equal "\x01".b, CBOR.dump(1)
    assert_equal "\x18\x2a".b, CBOR.dump(42)
    assert_equal "\x18\x64".b, CBOR.dump(100)
    assert_equal "\x1a\x00\x0f\x42\x40".b, CBOR.dump(1000000)
    assert_equal "\x1b\x00\x00\x00\xe8\xd4\xa5\x10\x00".b, CBOR.dump(1000000000000)
  end

  def test_dump_large_int
    assert_raises CBOR::CborError do
      CBOR.dump(18446744073709551616)
    end
  end

  def test_dump_nints
    assert_equal "\x20".b, CBOR.dump(-1)
    assert_equal "\x38\x63".b, CBOR.dump(-100)
    assert_equal "\x39\x03\xe7".b, CBOR.dump(-1000)
    assert_equal "\x3b\x00\x00\x00\xe8\xd4\xa5\x0f\xff".b, CBOR.dump(-1000000000000)
  end

  def test_dump_floats
    assert_equal "\xfb\x3f\xf1\x99\x99\x99\x99\x99\x9a".b, CBOR.dump(1.1)
    assert_equal "\xfb\x7e\x37\xe4\x3c\x88\x00\x75\x9c".b, CBOR.dump(1.0e+300)
  end

  def test_dump_strings
    assert_equal "\x42\xc3\x28".b, CBOR.dump("\xc3\x28")
    assert_equal "\x66foobar".b, CBOR.dump("foobar")
    assert_equal "\x66foobar".b, CBOR.dump(:foobar)
    assert_equal "\x67f\xc3\xb6obar".b, CBOR.dump("föobar")
  end

  def test_dump_collections
    assert_equal "\x82\x63foo\x63bar".b, CBOR.dump(["foo", "bar"])
    # The exact order of keys in an object is undefined
    assert_equal "\xa2\x63foo\x01\x63bar\x02".b, CBOR.dump({foo: 1, bar: 2})
  end

  def test_dump_times
    assert_equal "\xc0\x78\x1b\x32\x30\x31\x33\x2d\x30\x33\x2d\x32\x31\x54\x32\x30\x3a\x30\x34\x3a\x30\x30.000000\x5a".b, CBOR.dump(Time.iso8601("2013-03-21T20:04:00Z"))
    assert_equal "\xc0\x78\x1b\x32\x30\x31\x33\x2d\x30\x33\x2d\x32\x31\x54\x32\x30\x3a\x30\x34\x3a\x30\x30.000001\x5a".b, CBOR.dump(Time.iso8601("2013-03-21T20:04:00.000001Z"))
  end

  def test_dump_bigdecimal
    assert_equal "\xc4\x82\x21\x19\x6a\xb3".b, CBOR.dump(BigDecimal.new("273.15"))
  end

end
