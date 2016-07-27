defmodule Collision.Polygon.Vertex do
  @moduledoc """
  A vertex is a point in the Cartesian space where a polygon's
  edges meet.
  """
  defstruct x: 0, y: 0

  @typedoc """
  Vertices in two dimensional space are defied by `y` and `y` coordinates.
  """
  @type t :: t
end
