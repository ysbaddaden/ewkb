module Geos
  abstract class Geometry
    getter! srid : Int32

    abstract def type
    abstract def name
    abstract def coordinates
    abstract def as_text(io : IO)
    abstract def as_binary(formatter, include_srid = false)

    def as_text
      String.build { |text| as_text(text) }
    end

    def as_binary(include_srid : Bool = false)
      writer = WKB::Formatter.new
      as_binary(writer, include_srid: include_srid)
      writer.to_slice
    end

    macro inherited
      {% if @type.superclass.stringify == "Geos::Geometry" %}
        {% name = @type.name.stringify.split("::").last.upcase %}

        def name
          {{ name }}
        end

        {% for zm in %w(Z M ZM) %}
          class ::{{ @type.name }}{{ zm.id }} < ::{{ @type.name }}
            def type
              super.to_u32 | {% if zm == "ZM" %}
                               WKB::Z | WKB::M
                             {% elsif zm == "Z" %}
                               WKB::Z
                             {% elsif zm == "M" %}
                               WKB::M
                             {% else %}
                               0
                             {% end %}
            end

            def name
              {{ name + zm }}
            end
          end
        {% end %}
      {% end %}
    end
  end
end
