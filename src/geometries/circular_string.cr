require "./geometry"

module Geos
  class CircularString < Geometry
    getter points : Array(Point)

    def initialize(@points, @srid = Geos.default_srid)
    end

    def type
      8
    end

    def circle?
      points.size == 3 && points.first == points.last
    end

    def coordinates
      points.map(&:coordinates)
    end

    def as_text(io : IO)
      io << name
      Point.collection_as_text(points, io)
    end
  end
end
