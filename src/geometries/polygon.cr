require "./geometry"

module Geos
  class Polygon < Geometry
    getter shapes : Array(Array(Point))

    def initialize(@shapes, @srid = Geos.default_srid)
    end

    def type
      2
    end

    def exterior
      shapes.first
    end

    def interiors
      shapes[1 .. -1]
    end

    def coordinates
      shapes.map(&:coordinates)
    end

    def as_text(io : IO)
      io << name << "("
      shapes.each_with_index do |points, index|
        io << ", " unless index == 0
        Point.collection_as_text(points, io)
      end
      io << ")"
    end
  end
end
