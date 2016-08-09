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

  @doc """
  Convert a tuple to a Vertex.

  Returns: %Vertex{}

  ## Example

      iex> Vertex.from_tuple({2, 5})
      %Vertex{x: 2, y: 5}

  """
  @spec from_tuple({number, number}) :: Vertex.t
  def from_tuple({x, y}) do
    %Vertex{x: x, y: y}
  end

  @doc """
  Convert a vertex to a tuple.

  Returns: {}

  ## Example

      iex> Vertex.to_tuple(%Vertex{x: 2, y: 5})
      {2, 5}

  """
  @spec to_tuple(Vertex.t) :: {number, number}
  def to_tuple(%Vertex{x: x, y: y}) do
    {x, y}
  end

  @doc """
  Determinant of the triangle formed by three vertices.

  If > 0, counter-clockwise
     = 0, colinear
     < 0, clockwise
  """
  @spec determinant(Vertex.t, Vertex.t, Vertex.t) :: number
  defp determinant(%Vertex{} = v1, %Vertex{} = v2, %Vertex{} = v3) do
    (v2.x - v1.x)*(v3.y - v1.y) - (v2.y - v1.y)*(v3.x - v1.x)
  end
  defp counter_clockwise(v1, v2, v3) do
    determinant(v1, v2, v3) > 0
  end

  @doc """
  Calculate the convex hull of a list of vertices.

  In the case of a convex polygon, it returns the polygon's vertices.

  For a concave polygon, it returns a subset of the vertices that form a
  convex polygon.

  ## Examples

      iex> convex_polygon = [
      ...>   %Vertex{x: 2, y: 2}, %Vertex{x: -2, y: 2},
      ...>   %Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2}
      ...> ]
      ...> Vertex.graham_scan(convex_polygon)
      [%Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2},
       %Vertex{x: 2, y: 2}, %Vertex{x: -2, y: 2}]

      iex> concave_polygon = [
      ...>   %Vertex{x: 2, y: 2}, %Vertex{x: 0, y: 0}, %Vertex{x: -2, y: 2},
      ...>   %Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2}
      ...> ]
      ...> Vertex.graham_scan(concave_polygon)
      [%Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2},
      %Vertex{x: 2, y: 2}, %Vertex{x: -2, y: 2}]

  """
  # Adapted from:
  # https://gotorecursive.wordpress.com/2014/05/28/grahams-scan-from-imperative-to-functional/
  @spec graham_scan([Vertex.t]) :: Vertex.t
  def graham_scan(vertices) do
    min_point = Enum.min_by(vertices, fn vertex -> [vertex.y, vertex.x] end)
    distance_to_min = vertices
    |> Enum.sort_by(fn vertex ->
      :math.atan2(vertex.y - min_point.y, vertex.x - min_point.x)
    end)

    add_to_hull = fn point, hull ->
      [point | filter_right_turns(point, hull)]
    end

    convex_hull = distance_to_min
    |> List.foldl([], add_to_hull)
    |> Enum.reverse
    convex_hull
  end
  # During the scan, filter out the most recently added
  # point if it makes a reflex angle with the new point.
  defp filter_right_turns(new_point, hull) do
    hull
    |> List.foldr([], fn (current_point, current_hull) ->
      case current_hull do
        [previous | _] ->
          if counter_clockwise(previous, current_point, new_point) do
            [current_point | current_hull]
          else
            current_hull
          end
        _ ->
          [current_point | current_hull]
      end
    end)
  end


  @doc """
  Rounds the x and y components of a vertex.

  Returns: Vertex.t

  ## Examples

      iex> Vertex.round_vertex(%Vertex{x: 1.9999999, y: 1.9999999})
      %Vertex{x: 2.0, y: 2.0}

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

      iex> Vertex.round_vertices([
      ...>   %Vertex{x: 1.9999999, y: 1.99999999}, %Vertex{x: 2.11111111, y: 2.11111111}
      ...> ])
      [%Vertex{x: 2.0, y: 2.0}, %Vertex{x: 2.11111, y: 2.11111}]

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
