require "./wkt"
require "../geometries/*"

module Geos
  module WKT
    class Parser
      class Error < Error
        def initialize(type)
          super "unsupported type: #{ type }"
        end
      end

      class ParseError < Error
        def self.new(expected, got)
          new "expected #{ expected.inspect } but got #{ got.inspect }"
        end

        def self.new(got)
          new "unexpected #{ got.inspect }"
        end
      end

      WORD = ('a' .. 'z').to_a + ('A' .. 'Z').to_a
      INTEGER = ('0' .. '9').to_a
      FLOAT = INTEGER + ['.']
      WHITESPACE = [' ', '\t', '\r', '\n']

      getter :text

      def initialize(@text : String)
        @offset = 0
        @types = [] of String
        @srid = [] of Int32
        @has_z = [] of Bool
        @has_m = [] of Bool
      end

      def parse
        parse_headers do
          case type
          when "POINT" then parse_point
          when "LINESTRING" then parse_line_string
          when "CIRCULARSTRING" then parse_circular_string
          when "COMPOUNDCURVE" then parse_compound_curve
          when "CURVEPOLYGON" then parse_curve_polygon
          when "POLYGON" then parse_polygon
          when "TRIANGLE" then parse_triangle
          #when "MULTIPOINT" then parse_multi_point
          #when "MULTICURVE" then parse_multi_curve
          #when "MULTILINESTRING" then parse_multi_line_string
          #when "MULTISURFACE" then parse_multi_surface
          #when "MULTIPOLYGON" then parse_multi_polygon
          #when "TIN" then parse_tin
          #when "GEOMETRYCOLLECTION" then parse_geometry(collection)
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
        points = [] of Point

        loop do
          points << parse_point
          break if peek == ')'
          expect ','
        end

        find(LineString).new(points, srid)
      end

      def parse_circular_string
        points = [] of Point

        loop do
          points << parse_point
          break if peek == ')'
          expect ','
        end

        find(CircularString).new(points, srid)
      end

      def parse_compound_curve
        curves = [] of LineString | CircularString

        loop do
          parse_headers do
            curves << parse_curve
          end
          break unless peek == ','
          expect ','
        end

        find(CompoundCurve).new(curves, srid)
      end

      def parse_curve
        case type
        when "LINESTRING" then parse_line_string
        when "CIRCULARSTRING" then parse_circular_string
        else raise Error.new(type)
        end
      end

      def parse_curve_polygon
        shapes = [] of Ring | Polygon | Triangle

        loop do
          shapes << parse_ring
          break unless peek == ','
          expect ','
        end

        find(CurvePolygon).new(shapes, srid)
      end

      def parse_polygon
        find(Polygon).new(parse_linear_rings, srid)
      end

      def parse_triangle
        find(Triangle).new(parse_linear_rings, srid)
      end

      def parse_linear_ring
        points = LinearRing.new
        expect '('

        loop do
          points << parse_point
          break if peek == ')'
          expect ','
        end

        expect ')'
        points
      end

      private def parse_linear_rings
        shapes = [] of LinearRing

        loop do
          shapes << parse_linear_ring
          break if peek == ')'
          expect ','
        end

        shapes
      end

      def parse_ring
        parse_headers do
          case type
          when "LINESTRING" then parse_line_string
          when "CIRCULARSTRING" then parse_circular_string
          when "COMPOUNDCURVE" then parse_compound_curve
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
        type = parse_word

        if type == "SRID"
          expect '='
          @srid << (srid = parse_int32)
          expect ';'
          type = parse_word
        end

        if type.ends_with?("ZM")
          @has_z << true
          @has_m << true
          type = type[0 .. -3]
        elsif type.ends_with?("Z")
          @has_z << true
          @has_m << false
          type = type[0 .. -2]
        elsif type.ends_with?("M")
          @has_z << false
          @has_m << true
          type = type[0 .. -2]
        else
          @has_z << false
          @has_m << false
        end

        @types << type

        expect '('
        result = yield
        expect ')'

        result
      ensure
        @types.pop
        @has_z.pop
        @has_m.pop
        @srid.pop if srid
      end

      private def parse_word
        read(WORD).upcase
      end

      private def parse_int32
        read(INTEGER).to_i32
      end

      private def parse_float64
        read(FLOAT).to_f64
      end

      private def read(chars)
        skip_whitespace

        size = 0
        while chars.includes?(text[@offset + size])
          size += 1
        end

        raise ParseError.new(peek) if size == 0
        text[@offset, size].tap { @offset += size }
      end

      private def expect(char)
        skip_whitespace

        if peek == char
          @offset += 1
        else
          raise ParseError.new(char, peek)
        end
      end

      private def skip_whitespace
        while WHITESPACE.includes?(peek)
          @offset += 1
        end
      end

      private def peek
        text[@offset]
      end
    end

    def self.parse(text)
      Parser.new(text).parse
    end
  end
end
