defmodule Collision.Polygon do
  @moduledoc """
  General, non-regular polygons.

  A general polygon is defined by its vertices; from these
  we can calculate the edges, centroid, rotation angles,
  and whether the polygon is concave or convex.
  """
  defstruct edges: [], vertices: []

  alias Collision.Polygon
  alias Collision.Polygon.Edge
  alias Collision.Polygon.Vertex
  alias Collision.Polygon.Helper

  @type t :: %Polygon{edges: [Edge.t]}
  @type axis :: {Vertex.t, Vertex.t}
  @type polygon :: t | Collision.Polygon.RegularPolygon.t
  @typep degrees :: number
  @typep radians :: number

  @spec from_vertices([Vertex.t]) :: t
  def from_vertices(vertices) do
    edges = vertices
    |> Stream.chunk(2, 1, [Enum.at(vertices, 0)])
    |> Enum.map(fn [point1, point2] ->
      Edge.from_vertex_pair({point1, point2})
    end)
    %Polygon{edges: edges, vertices: vertices}
  end

  @doc """
  Translate a polygon's vertices.

  ## Examples

  """
  @spec translate_polygon(Polygon.t, %{x: number, y: number}) :: Polygon.t
  def translate_polygon(polygon, %{x: _x, y: _y} = translation) do
    polygon.vertices
    |> Enum.map(translate_vertex(translation))
    |> from_vertices
  end
  defp translate_vertex(%{x: x_translate, y: y_translate}) do
    fn %{x: x, y: y} -> %Vertex{x: x + x_translate, y: y + y_translate} end
  end

  @doc """
  Rotate a regular polygon using rotation angle in degrees.

  ## Examples

  """
  @spec rotate_polygon_degrees(Polygon.t, degrees) :: Polygon.t
  def rotate_polygon_degrees(polygon, degrees) do
    angle_in_radians = Helper.degrees_to_radians(degrees)
    rotate_polygon(polygon, angle_in_radians)
  end

  @doc """
  Rotate a regular polygon, rotation angle should be radians.

  The rotation point is the point around which the polygon is rotated.
  It defaults to the origin, so without specifying the polygon's
  centroid as the rotation point, it will not be an in-place rotation.

  ## Examples

  """
  @spec rotate_polygon(Polygon.t, radians, %{x: number, y: number}) :: Polygon.t
  def rotate_polygon(polygon, radians, rotation_point \\ %{x: 0, y: 0}) do
    rotate = rotate_vertex(radians, rotation_point)
    polygon.vertices
    |> Enum.map(fn vertex -> rotate.(vertex) end)
    |> from_vertices
  end
  defp rotate_vertex(radians, rotation_point) do
    fn %{x: x, y: y} ->
      x_offset = x - rotation_point.x
      y_offset = y - rotation_point.y
      x_term = rotation_point.x + (x_offset * :math.cos(radians) - y_offset * :math.sin(radians))
      y_term = rotation_point.y + (x_offset * :math.sin(radians) + y_offset * :math.cos(radians))
      %Vertex{x: x_term, y: y_term}
    end
  end

  @doc """
  Rounds the x and y components of an {x, y} tuple.

  ## Examples

  """
  @spec round_vertices([{number, number}]) :: [{number, number}]
  def round_vertices(vertices) do
    vertices
    |> Enum.map(fn {x, y} ->
      {Float.round(x, 5), Float.round(y, 5)}
    end)
  end
end
