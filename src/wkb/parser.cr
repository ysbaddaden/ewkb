require "./wkb"
require "../geometries/*"

module Geos
  module WKB
    class Parser
      class Error < Error
        getter type : Type

        def initialize(@type)
          super "unsupported type: 0x#{ type.value.to_s(16) }"
        end
      end

      getter binary

      def initialize(@binary : Slice(UInt8))
        @offset = 0
        @endianess = [] of UInt8
        @types = [] of Type
        @srid = [] of Int32
        @has_z = [] of Bool
        @has_m = [] of Bool
      end

      def self.new(hexstr : String)
        slice = Slice(UInt8).new(hexstr.bytesize / 2) { |i| hexstr[i * 2, 2].to_u8(16) }
        Parser.new(slice)
      end

      def parse
        parse_headers do
          case type
          when Type::Point then parse_point
          when Type::LineString then parse_line_string
          when Type::CircularString then parse_circular_string
          when Type::CompoundCurve then parse_compound_curve
          when Type::CurvePolygon then parse_curve_polygon
          when Type::Polygon then parse_polygon
          when Type::Triangle then parse_triangle
          #when Type::MultiPoint then parse_multi_point
          #when Type::MultiCurve then parse_multi_curve
          #when Type::MultiLineString then parse_multi_line_string
          #when Type::MultiSurface then parse_multi_surface
          #when Type::MultiPolygon then parse_multi_polygon
          #when Type::Tin then parse_tin
          #when Type::GeometryCollection then parse_geometry(collection)
          else raise Error.new(type)
          end
        end
      end

      def parse_point
        x, y = parse_float64, parse_float64
        z = parse_float64 if z?
        m = parse_float64 if m?
        Point.new(x, y, z, m, srid)
      end

      def parse_line_string
        points = Array(Point).new(parse_num) { parse_point }
        find(LineString).new(points, srid)
      end

      def parse_circular_string
        points = Array(Point).new(parse_num) { parse_point }
        find(CircularString).new(points, srid)
      end

      def parse_compound_curve
        curves = Array(LineString | CircularString).new(parse_num) do
          parse_headers do
            case type
            when Type::LineString then parse_line_string
            when Type::CircularString then parse_circular_string
            else raise Error.new(type)
            end
          end
        end
        find(CompoundCurve).new(curves, srid)
      end

      def parse_curve_polygon
        shapes = Array(Ring | Polygon | Triangle).new(parse_num) { parse_ring }
        find(CurvePolygon).new(shapes, srid)
      end

      def parse_polygon
        shapes = Array(LinearRing).new(parse_num) { parse_linear_ring }
        find(Polygon).new(shapes, srid)
      end

      def parse_triangle
        shapes = Array(LinearRing).new(parse_num) { parse_linear_ring }
        find(Triangle).new(shapes, srid)
      end

      def parse_linear_ring
        LinearRing.new(parse_num) { parse_point }
      end

      def parse_ring
        parse_headers do
          case type
          when Type::LineString then parse_line_string
          when Type::CircularString then parse_circular_string
          when Type::CompoundCurve then parse_compound_curve
          else raise Error.new(type)
          end
        end
      end

      # :nodoc:
      macro find(klass_name)
        if z?
          if m?
            {{ klass_name.id }}ZM
          else
            {{ klass_name.id }}Z
          end
        elsif m?
          {{ klass_name.id }}M
        else
          {{ klass_name.id }}
        end
      end

      def byte_order
        @endianess.last
      end

      def z?
        !!@has_z.last?
      end

      def m?
        !!@has_m.last?
      end

      def type
        @types.last
      end

      def srid
        @srid.last? || Geos.default_srid
      end

      private def parse_headers
        @endianess << parse_uint8
        type = parse_uint32

        if type & SRID > 0
          type -= SRID
          @srid << (srid = parse_uint32.to_i)
        end

        if type & Z > 0
          type -= Z
          @has_z << (has_z = true)
        end

        if type & M > 0
          type -= M
          @has_m << (has_m = true)
        end

        @types << Type.from_value(type)

        yield
      ensure
        @endianess.pop
        @types.pop
        @has_z.pop if has_z
        @has_m.pop if has_m
        @srid.pop if srid
      end

      private def parse_num
        parse_uint32.to_i
      end

      private def parse_uint8
        binary[@offset].tap { @offset += 1 }
      end

      private def parse_uint32
        (read(4) as Pointer(UInt32)).value
      end

      private def parse_float64
        (read(8) as Pointer(Float64)).value
      end

      private def read(size : Int)
        slice = binary[@offset, size]
        @offset += size

        if byte_order != SYSTEM_ENDIAN
          slice = Slice(UInt8).new(size) { |i| slice[size - i - 1] }
        end

        slice.pointer(size)
      end
    end

    def self.parse(binary)
      Parser.new(binary).parse
    end
  end
end
