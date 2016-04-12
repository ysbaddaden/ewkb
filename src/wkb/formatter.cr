module Geos
  module WKB
    class Formatter
      def initialize(capacity : Int = 64)
        @capacity = capacity
        @buffer = GC.malloc_atomic(capacity.to_u32) as UInt8*
        @buffer[0] = SYSTEM_ENDIAN
        @bytesize = 1
        @pos = 1
      end

      def write_header(type, srid = 0, include_srid = false)
        if include_srid && srid && srid > 0
          write_uint32(type | WKB::SRID)
          write_uint32(srid)
        else
          write_uint32(type)
        end
      end

      def write_uint32(value)
        uint = value.to_u32
        buffer = (pointerof(uint) as UInt8[4]*).value
        write buffer.to_slice
      end

      def write_float64(value)
        float = value.to_f64
        buffer = (pointerof(float) as UInt8[8]*).value
        write buffer.to_slice
      end

      def write(slice : Slice(UInt8))
        count = slice.size
        return if count == 0

        new_bytesize = @pos + count
        if new_bytesize > @capacity
          resize_to_capacity(Math.pw2ceil(new_bytesize))
        end

        slice.copy_to(@buffer + @pos, count)

        if @pos > @bytesize
          Intrinsics.memset((@buffer + @bytesize) as Void*, 0_u8, (@pos - @bytesize).to_u32, 0_u32, false)
        end

        @pos += count
        @bytesize = @pos if @pos > @bytesize

        nil
      end

      def to_slice
        Slice.new(@buffer, @bytesize)
      end

      private def resize_to_capacity(capacity)
        @capacity = capacity
        @buffer = @buffer.realloc(@capacity)
      end
    end
  end
end
