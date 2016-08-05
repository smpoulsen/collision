defmodule Collision.Polygon.Vertex do
  @moduledoc """
  A vertex is a point in the Cartesian space where a polygon's
  edges meet.
  """
  defstruct x: 0, y: 0

  alias Collision.Polygon.Vertex

  @typedoc """
  Vertices in two dimensional space are defined by `x` and `y` coordinates.
  """
  @type t :: Vertex.t

  @spec to_tuple(Vertex.t) :: {number, number}
  def to_tuple(%Vertex{x: x, y: y}) do
    {x, y}
  end

  @doc """
  Rounds the x and y components of a vertex.

  Returns: Vertex.t

  ## Examples

  """
  @spec round_vertex(Vertex.t) :: Vertex.t
  def round_vertex(%Vertex{x: x, y: y}) when (is_float(x) and is_float(y)) do
    %Vertex{x: Float.round(x, 5), y: Float.round(y, 5)}
  end
  def round_vertex(%Vertex{x: x, y: y}) when (is_integer(x) and is_integer(y)) do
    %Vertex{x: x, y: y}
  end

  @doc """
  Rounds a list of vertices.

  Returns: [Vertex.t]

  ## Examples
  """
  @spec round_vertices([Vertex.t]) :: [Vertex.t]
  def round_vertices(vertices) do
    vertices
    |> Enum.map(&round_vertex/1)
  end

  defimpl String.Chars, for: Vertex do
    @spec to_string(Vertex.t) :: String.t
    def to_string(%Vertex{} = v) do
      "{#{v.x}, #{v.y}}"
    end
  end
end
