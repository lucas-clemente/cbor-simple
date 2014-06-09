require "test_helper"

class TestLoad < Minitest::Test
  def test_loading
    TEST_DATA.each do |bin, val|
      assert_equal val, CBOR.load(bin), "loading #{val.inspect}"
    end
  end

  def test_loading_from_junk
    assert_raises CBOR::CborError do
      CBOR.load(5)
    end
  end
end
