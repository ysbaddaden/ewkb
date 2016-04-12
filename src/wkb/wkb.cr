module Geos::WKB
  class Error < Exception
  end

  SRID = 0x20000000_u32
  M = 0x40000000_u32
  Z = 0x80000000_u32

  enum Type : UInt32
    Point = 1
    LineString = 2
    Polygon = 3
    MultiPoint = 4
    MultiLineString = 5
    MultiPolygon = 6
    GeometryCollection = 7
    CircularString = 8
    CompoundCurve = 9
    CurvePolygon = 10
    MultiCurve = 11
    MultiSurface = 12
    PolyhedralSurface = 15
    Tin = 16
    Triangle = 17
  end
end

require "./parser"
require "./formatter"
