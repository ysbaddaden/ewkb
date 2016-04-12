require "../test_helper"
require "../../src/wkt"

module Geos
  class WKT::ParserTest < Minitest::Test
    def test_point
      point = WKT.parse("POINT(0 0)") as Point
      assert_equal({0, 0}, {point.x, point.y})
      assert_equal 0, point.srid

      point = WKT.parse("SRID=4326;POINT(0 0)") as Point
      assert_equal({0, 0}, {point.x, point.y})
      assert_equal 4326, point.srid

      point = WKT.parse("SRID = 32632 ; POINT ( 0 0 )") as Point
      assert_equal({0, 0}, {point.x, point.y})
      assert_equal 32632, point.srid

      point = WKT.parse("POINT(123.45 543.21)") as Point
      assert_equal({123.45, 543.21}, {point.x, point.y})

      point = WKT.parse("POINTZ(10 20 30)") as PointZ
      assert_equal({10, 20, 30}, {point.x, point.y, point.z})

      point = WKT.parse("POINTZM(10 20 30 40)") as PointZM
      assert_equal({10, 20, 30, 40}, {point.x, point.y, point.z, point.m})

      point = WKT.parse("POINTM(10 20 40)") as PointM
      assert_equal({10, 20, 40}, {point.x, point.y, point.m})
    end

    def test_line_string
      line_string = WKT.parse("LINESTRING(0 0, 1 1, 1 2)") as LineString
      assert_equal [{0, 0}, {1, 1}, {1, 2}], to_tuple(line_string.points)
    end

    def test_polygon
      polygon = WKT.parse("POLYGON((0 0, 4 0, 4 4, 0 4, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))") as Polygon
      assert_equal [{0, 0}, {4, 0}, {4, 4}, {0, 4}, {0, 0}], to_tuple(polygon.exterior)
      assert_equal [[{1, 1}, {2, 1}, {2, 2}, {1, 2}, {1, 1}]], polygon.interiors.map { |pts| to_tuple(pts) }
    end

    def test_triangle
      triangle = WKT.parse("TRIANGLE((0 0, 0 9, 9 0, 0 0))") as Triangle
      assert_equal [{0, 0}, {0, 9}, {9, 0}, {0, 0}], to_tuple(triangle.exterior)
      assert_empty triangle.interiors
      #assert_equal "0111000000010000000400000000000000000000000000000000000000000000000000000000000000000022400000000000002240000000000000000000000000000000000000000000000000", triangle.as_binary
    end

    def test_circular_string
      circular_string = WKT.parse("CIRCULARSTRING(1 1, 2 2, 1 1)") as CircularString
      assert_equal [{1, 1}, {2, 2}, {1, 1}], to_tuple(circular_string.points)
    end

    def test_curve_polygon
      curve_polygon = WKT.parse("CURVEPOLYGON(CIRCULARSTRING(2.68428 58.5378, 2.68428 48.5378, 2.68428 58.5378))") as CurvePolygon
      shape = curve_polygon.exterior as CircularString
      #assert_equal [{2.68428, 58.5378}, {2.68428, 48.5378}, {2.68428, 58.5378}], to_tuple(shape.points)
      assert_empty curve_polygon.interiors
      assert curve_polygon.circle?
      #assert_equal "010A000020E6100000010000000108000000030000000B0000A0677905408A111B44D6444D400B0000A0677905408A111B44D64448400B0000A0677905408A111B44D6444D40", curve_polygon.as_binary

      curve_polygon = WKT.parse("CURVEPOLYGON(CIRCULARSTRING(2.68428 58.5378, 2.68428 48.5378, 2.68428 58.5378), CIRCULARSTRING(1 1, 2 2, 1 1))") as CurvePolygon
      curve_polygon.exterior as CircularString
      curve_polygon.interiors[0] as CircularString
      #assert_equal "010A000020E6100000020000000108000000030000000B0000A0677905408A111B44D6444D400B0000A0677905408A111B44D64448400B0000A0677905408A111B44D6444D40010800000003000000000000000000F03F000000000000F03F00000000000000400000000000000040000000000000F03F000000000000F03F", curve_polygon.as_binary
    end

    def test_compound_curve
      compound = WKT.parse("COMPOUNDCURVE(LINESTRING(0 0, 1 1), CIRCULARSTRING(2 2, 3 3, 4 4))") as CompoundCurve
      line = compound.curves[0] as LineString
      circular = compound.curves[1] as CircularString
      assert_equal [{0, 0}, {1, 1}], to_tuple(line.points)
      assert_equal [{2, 2}, {3, 3}, {4, 4}], to_tuple(circular.points)
    end

    private def to_tuple(points)
      points.map { |pt| {pt.x, pt.y} }
    end
  end
end
