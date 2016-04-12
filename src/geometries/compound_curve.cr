require "./geometry"

module Geos
  class CompoundCurve < Geometry
    getter curves : Array(Geometry)

    def initialize(@curves, @srid = Geos.default_srid)
    end

    def type
      9
    end

    def coordinates
      curves.map(&:coordinates)
    end

    def as_text(io : IO)
      io << name << '('
      curves.each_with_index do |curve, index|
        io << ", " unless index == 0
        curve.as_text(io)
      end
      io << ')'
    end
  end
end
