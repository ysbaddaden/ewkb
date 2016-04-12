require "./geometry"

module Geos
  class Point < Geometry
    getter x : Float64
    getter y : Float64

    def initialize(x, y, @srid = Geos.default_srid)
      @x = x.to_f64
      @y = y.to_f64
    end

    def type
      1
    end

    def self.new(x, y, z, m, srid)
      if z
        if m
          PointZM.new(x, y, z, m, srid)
        else
          PointZ.new(x, y, z, srid)
        end
      elsif m
        PointM.new(x, y, m, srid)
      else
        Point.new(x, y, srid)
      end
    end

    def ==(other : Point)
      x == other.x && y == other.y && srid == other.srid
    end

    def ==(other)
      false
    end

    def lon
      x
    end

    def longitude
      x
    end

    def lat
      y
    end

    def latitude
      y
    end

    def coordinates
      [x, y]
    end

    def as_text(io : IO)
      io << name << "("
      as_simple_text(io)
      io << ")"
    end

    def as_simple_text(io : IO)
      io << x << " " << y
    end

    def self.collection_as_text(points, io : IO)
      io << "("
      points.each_with_index do |point, index|
        io << ", " unless index == 0
        if point.responds_to?(:as_simple_text)
          point.as_simple_text(io)
        else
          point.as_text(io)
        end
      end
      io << ")"
    end

    def as_binary(writer, include_srid = false)
      writer.write_header(type, srid, include_srid: include_srid)
      writer.write_float64(x)
      writer.write_float64(y)
    end
  end

  class PointZ < Point
    getter z : Float64

    def initialize(x, y, z, srid = 0)
      super(x, y, srid)
      @z = z.to_f64
    end

    def ==(other : PointZ)
      super && z == other.z
    end

    def coordinates
      [x, y, z]
    end

    def as_simple_text(io : IO)
      super
      io << " " << z if z
    end

    def as_binary(writer, include_srid = false)
      super
      writer.write_float64(z)
    end
  end

  class PointZM < Point
    getter z : Float64
    getter m : Float64

    def initialize(x, y, z, m, srid = 0)
      super(x, y, srid)
      @z = z.to_f64
      @m = m.to_f64
    end

    def ==(other : PointZM)
      super && z == other.z && m == other.m
    end

    def coordinates
      [x, y, z, m]
    end

    def as_simple_text(io : IO)
      super
      io << " " << z if z
      io << " " << m if m
    end

    def as_binary(writer, include_srid = false)
      super
      writer.write_float64(z)
      writer.write_float64(m)
    end
  end

  class PointM < Point
    getter m : Float64

    def initialize(x, y, m, srid = 0)
      super(x, y, srid)
      @m = m.to_f64
    end

    def ==(other : PointM)
      super && m == other.m
    end

    def coordinates
      [x, y, m]
    end

    def as_simple_text(io : IO)
      super
      io << " " << m if m
    end

    def as_binary(writer, include_srid = false)
      super
      writer.write_float64(m)
    end
  end
end
