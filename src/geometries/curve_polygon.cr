require "./geometry"

module Geos
  class CurvePolygon < Geometry
    getter shapes : Array(Geometry)

    def initialize(@shapes, @srid = Geos.default_srid)
    end

    def type
      10
    end

    def exterior
      shapes.first
    end

    def interiors
      shapes[1 .. -1]
    end

    def circle?
      if interiors.empty? && (shape = exterior).responds_to?(:circle?)
        shape.circle?
      else
        false
      end
    end

    def coordinates
      shapes.map(&:coordinates)
    end

    def as_text(io : IO)
      io << name << "("
      shapes.each_with_index do |shape, index|
        io << ", " unless index == 0
        shape.as_text(io)
      end
      io << ")"
    end
  end
end
