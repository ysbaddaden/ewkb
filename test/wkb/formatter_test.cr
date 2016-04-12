require "../test_helper"

module Geos
  class WKB::FormatterTest < Minitest::Test
    def test_point
      point = Point.new(0, 0)
      assert_equal "010100000000000000000000000000000000000000", point.as_binary.hexstring

      point = Point.new(0, 0, 4326)
      assert_equal "010100000000000000000000000000000000000000", point.as_binary.hexstring

      point = Point.new(0, 0, 4326)
      point.as_binary(include_srid: true).hexstring
      assert_equal "0101000020e610000000000000000000000000000000000000", point.as_binary(include_srid: true).hexstring

      point = PointZ.new(0, 0, 0)
      assert_equal "0101000080000000000000000000000000000000000000000000000000", point.as_binary.hexstring

      point = PointZM.new(0, 0, 0, 0)
      assert_equal "01010000c00000000000000000000000000000000000000000000000000000000000000000", point.as_binary.hexstring

      point = PointM.new(0, 0, 0)
      assert_equal "0101000040000000000000000000000000000000000000000000000000", point.as_binary.hexstring

      point = Point.new(1, 2)
      assert_equal "0101000000000000000000f03f0000000000000040", point.as_binary.hexstring
      assert_equal point, WKB.parse(point.as_binary)

      point = Point.new(123.45, 543.21)
      assert_equal "0101000000cdccccccccdc5e4048e17a14aef98040", point.as_binary.hexstring
      assert_equal point, WKB.parse(point.as_binary)
    end
  end
end
