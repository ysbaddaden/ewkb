require "./line_string"
require "./circular_string"
require "./compound_curve"

module Geos
  alias Ring = LineString | CircularString | CompoundCurve
end
