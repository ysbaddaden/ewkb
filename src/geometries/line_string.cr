require "./geometry"

module Geos
  class LineString < Geometry
    getter points : Array(Point)

    def initialize(@points, @srid = Geos.default_srid)
    end

    def type
      2
    end

    def coordinates
      points.map(&:coordinates)
    end

    def as_text(io : IO)
      io << name << "("
      points.each_with_index do |point, index|
        io << ", " unless index == 0
        point.as_simple_text(io)
      end
      io << ")"
    end
  end
end
