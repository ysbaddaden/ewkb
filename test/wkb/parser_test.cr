require "../test_helper"

module Geos
  class WKB::ParserTest < Minitest::Test
    def test_point
      point = WKB.parse("010100000000000000000000000000000000000000") as Point
      assert_equal({0, 0}, {point.x, point.y})
      assert_equal 0, point.srid
      assert_equal "POINT(0 0)", point.as_text

      point = WKB.parse("0101000020E610000000000000000000000000000000000000") as Point
      assert_equal({0, 0}, {point.x, point.y})
      assert_equal 4326, point.srid
      assert_equal "POINT(0 0)", point.as_text

      point = WKB.parse("0101000020787F000000000000000000000000000000000000") as Point
      assert_equal({0, 0}, {point.x, point.y})
      assert_equal 32632, point.srid
      assert_equal "POINT(0 0)", point.as_text

      point = WKB.parse("0101000020E6100000CDCCCCCCCCDC5E4048E17A14AEF98040") as Point
      assert_equal({123.45, 543.21}, {point.x, point.y})
      assert_equal "POINT(123.45 543.21)", point.as_text

      point = WKB.parse("01010000A0E6100000000000000000244000000000000034400000000000003E40") as PointZ
      assert_equal({10, 20, 30}, {point.x, point.y, point.z})
      assert_equal "POINTZ(10 20 30)", point.as_text

      point = WKB.parse("01010000E0E6100000000000000000244000000000000034400000000000003E400000000000004440") as PointZM
      assert_equal({10, 20, 30, 40}, {point.x, point.y, point.z, point.m})
      assert_equal "POINTZM(10 20 30 40)", point.as_text

      point = WKB.parse("0101000060E6100000000000000000244000000000000034400000000000004440") as PointM
      assert_equal({10, 20, 40}, {point.x, point.y, point.m})
      assert_equal "POINTM(10 20 40)", point.as_text
    end

    def test_line_string
      line_string = WKB.parse("0102000020E61000000300000000000000000000000000000000000000000000000000F03F000000000000F03F000000000000F03F0000000000000040") as LineString
      assert_equal [{0, 0}, {1, 1}, {1, 2}], to_tuple(line_string.points)
      assert_equal "LINESTRING(0 0, 1 1, 1 2)", line_string.as_text
    end

    def test_polygon
      polygon = WKB.parse("0103000020E61000000200000005000000000000000000000000000000000000000000000000001040000000000000000000000000000010400000000000001040000000000000000000000000000010400000000000000000000000000000000005000000000000000000F03F000000000000F03F0000000000000040000000000000F03F00000000000000400000000000000040000000000000F03F0000000000000040000000000000F03F000000000000F03F") as Polygon
      assert_equal [{0, 0}, {4, 0}, {4, 4}, {0, 4}, {0, 0}], to_tuple(polygon.exterior)
      assert_equal [[{1, 1}, {2, 1}, {2, 2}, {1, 2}, {1, 1}]], polygon.interiors.map { |pts| to_tuple(pts) }
      assert_equal "POLYGON((0 0, 4 0, 4 4, 0 4, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))", polygon.as_text
    end

    def test_multi_point
      skip :todo
      #multi_point = WKB.parse("0104000020E6100000020000000101000000000000000000000000000000000000000101000000000000000000F03F0000000000000040") as MultiPoint
      #assert_equal [{0, 0}, {1, 2}], to_tuple(multi_point.points)
      #assert_equal "MULTIPOINT((0 0), (1 2))", multi_point.as_text
    end

    def test_multi_line_string
      skip :todo
      #multi_line_string = #  WKB.parse("0105000020E61000000200000001020000000300000000000000000000000000000000000000000000000000F03F000000000000F03F000000000000F03F0000000000000040010200000003000000000000000000004000000000000008400000000000000840000000000000004000000000000014400000000000001040") as MultiLineString
      #assert_equal [[{0, 0}, {1, 1}, {1, 2}], [{2, 3}, {3, 2}, {5, 4}]], to_tuple(multi_line_string.line_strings)
      #assert_equal "MULTILINESTRING((0 0, 1 1, 1 2), (2 3, 3 2, 5 4))", multi_line_string.as_text
    end

    def test_multi_polygon
      skip :todo
      #multi_polygon = WKB.parse("0106000020E61000000200000001030000000200000005000000000000000000000000000000000000000000000000001040000000000000000000000000000010400000000000001040000000000000000000000000000010400000000000000000000000000000000005000000000000000000F03F000000000000F03F0000000000000040000000000000F03F00000000000000400000000000000040000000000000F03F0000000000000040000000000000F03F000000000000F03F01030000000100000005000000000000000000F0BF000000000000F0BF000000000000F0BF00000000000000C000000000000000C000000000000000C000000000000000C0000000000000F0BF000000000000F0BF000000000000F0BF") as MultiPoint
      #assert_equal [{0, 0}, {4, 0}, {4, 4}, {0, 4}, {0, 0}], to_tuple(multi_polygon.polygons[0])
      #assert_equal [{1, 1}, {2, 1}, {2, 2}, {1, 2}, {1, 1}], to_tuple(multi_polygon.polygons[1])
      #assert_equal [{-1, -1}, {-1, -2}, {-2, -2}, {-2, -1}, {-1, -1}], to_tuple(multi_polygon.polygons[2])
      #assert_equal "MULTIPOLYGON(((0 0, 4 0, 4 4, 0 4, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)), ((-1 -1, -1 -2, -2 -2, -2 -1, -1 -1)))",  multi_polygon.as_text
    end

    def test_geometry_collection
      skip :todo
      #geometry_collection = WKB.parse("0107000020E6100000020000000101000000000000000000004000000000000008400102000000020000000000000000000040000000000000084000000000000008400000000000001040") as MultiPoint
      #point = geometry_collection.geometries[0] as Point
      #line_string = geometry_collection.geometries[1] as LineString

      #assert_equal({2, 3}, {point.x, point.y})
      #assert_equal [{2, 3}, {3, 4}], to_tuple(line_string.points)
      #assert_equal "GEOMETRYCOLLECTION(POINT(2 3), LINESTRING(2 3, 3 4))", geometry_collection.as_text
    end

    def test_multi_curve
      skip :todo
    end

    def test_polyhedral_surface
      skip :todo
    end

    def test_triangle
      triangle = WKB.parse("0111000000010000000400000000000000000000000000000000000000000000000000000000000000000022400000000000002240000000000000000000000000000000000000000000000000") as Triangle
      assert_equal [{0, 0}, {0, 9}, {9, 0}, {0, 0}], to_tuple(triangle.exterior)
      assert_empty triangle.interiors
      assert_equal "TRIANGLE((0 0, 0 9, 9 0, 0 0))", triangle.as_text
    end

    def test_tin
      skip :todo
    end

    def test_circular_string
      skip :missing_test
    end

    def test_compound_curve
      skip :todo
    end

    def test_curve_polygon
      curve_polygon = WKB.parse("010A000020E6100000010000000108000000030000000B0000A0677905408A111B44D6444D400B0000A0677905408A111B44D64448400B0000A0677905408A111B44D6444D40") as CurvePolygon
      shape = curve_polygon.exterior as CircularString
      #assert_equal [{2.68428, 58.5378}, {2.68428, 48.5378}, {2.68428, 58.5378}], to_tuple(shape.points)
      assert_empty curve_polygon.interiors
      assert curve_polygon.circle?
      assert_equal "CURVEPOLYGON(CIRCULARSTRING(2.68428 58.5378, 2.68428 48.5378, 2.68428 58.5378))", curve_polygon.as_text

      curve_polygon = WKB.parse("010A000020E6100000020000000108000000030000000B0000A0677905408A111B44D6444D400B0000A0677905408A111B44D64448400B0000A0677905408A111B44D6444D40010800000003000000000000000000F03F000000000000F03F00000000000000400000000000000040000000000000F03F000000000000F03F") as CurvePolygon
      curve_polygon.exterior as CircularString
      curve_polygon.interiors[0] as CircularString
      assert_equal "CURVEPOLYGON(CIRCULARSTRING(2.68428 58.5378, 2.68428 48.5378, 2.68428 58.5378), CIRCULARSTRING(1 1, 2 2, 1 1))", curve_polygon.as_text
    end

    def test_multi_surface
      skip :todo
    end

    private def to_tuple(points)
      points.map { |pt| {pt.x, pt.y} }
    end
  end
end
