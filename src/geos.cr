module Geos
  BIG_ENDIAN = 0_u8
  LITTLE_ENDIAN = 1_u8
  SYSTEM_ENDIAN = LITTLE_ENDIAN # FIXME: bold assumption

  macro attr_config(name, value)
    @@default_{{ name.id }} = {{ value }}

    def self.default_{{ name.id }}
      @@default_{{ name.id }}
    end

    def self.default_{{ name.id }}=(@@default_{{ name.id }})
    end
  end

  attr_config :srid, 0
  attr_config :byte_order, SYSTEM_ENDIAN
end

require "./wkb"
