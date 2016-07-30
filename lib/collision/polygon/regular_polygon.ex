defmodule Collision.Polygon.RegularPolygon do
  @moduledoc """
  A regular polygon is equiangular and equilateral, having all
  angles and all sides be equal respectively. With enough sides,
  a regular polygon tends toward a circle.
  """
  defstruct n_sides: 3, radius: 0, rotation_angle: 0.0, midpoint: %{x: 0, y: 0}

  alias Collision.Polygon.RegularPolygon
  alias Collision.Polygon.Helper
  alias Collision.Polygon.Vertex

  @typedoc """
  A regular polygon is defined by a number of sides, a radius,
  a rotation angle, and a center point `{x, y}`.
  """
  @type t :: Collision.Polygon.RegularPolygon.t
  @type axis :: {Vertex.t, Vertex.t}
  @type degrees :: number
  @type radians :: number

  @doc """
  Construct a regular polygon from a tuple.

  A polygon must have at least three sides.

  ## Examples
  iex> Collision.Polygon.RegularPolygon.from_tuple({0, 0, 0, {0, 0}})
  {:error, :polygon_must_have_at_least_three_sides}

  iex> Collision.Polygon.RegularPolygon.from_tuple({3, 2, 0, {0, 0}})
  {:ok, %Collision.Polygon.RegularPolygon{n_sides: 3, radius: 2,
  rotation_angle: 0.0, midpoint: %Collision.Polygon.Vertex{x: 0, y: 0}}}
  """
  @spec from_tuple({integer, number, number, {number, number}}, atom) :: RegularPolygon.t
  def from_tuple({s, _r, _a, {_x, _y}}, _d) when s < 3 do
    {:error, :polygon_must_have_at_least_three_sides}
  end
  def from_tuple({s, r, a, {x, y}}, :degrees) do
    angle_in_radians = Float.round(Helper.degrees_to_radians(a), 5)
    {:ok, %RegularPolygon{
      n_sides: s,
      radius: r,
      rotation_angle: angle_in_radians,
      midpoint: %Vertex{x: x, y: y}
    }}
  end
  def from_tuple({s, r, a, {x, y}}, :radians) do
    {:ok, %RegularPolygon{
        n_sides: s,
        radius: r,
        rotation_angle: a,
        midpoint: %Vertex{x: x, y: y}
     }}
  end
  def from_tuple({s, r, a, {x, y}}), do: from_tuple({s, r, a, {x, y}}, :degrees)

  @doc """
  Determine the vertices, or points, of the polygon.

  ## Example

  iex> Collision.Polygon.RegularPolygon.calculate_vertices(
  ...>   %Collision.Polygon.RegularPolygon{
  ...>     n_sides: 4, radius: 2, rotation_angle: 0, midpoint: %{x: 2, y: 0}
  ...>   })
  [{4.0, 0.0}, {2.0, 2.0}, {0.0, 0.0}, {2.0, -2.0}]
  """
  @spec calculate_vertices(t) :: [Vertex.t]
  def calculate_vertices(%RegularPolygon{n_sides: s}) when s < 3 do
    {:invalid_number_of_sides}
  end
  def calculate_vertices(%RegularPolygon{n_sides: s, rotation_angle: a} = polygon) do
    rotation_angle = 2 * :math.pi / s
    vertices = 0..s - 1
    |> Enum.map(fn (n) ->
      calculate_vertex(%{polygon | rotation_angle: rotation_angle}, n)
    end)
    rotate_polygon(vertices, a)
  end

  # Find the vertex of a side of a regular polygon given the polygon struct
  # and an integer representing a side.
  @spec calculate_vertex(RegularPolygon.t, integer) :: Vertex.t
  defp calculate_vertex(
        %RegularPolygon{
          radius: r,
          rotation_angle: a,
          midpoint: %{x: x, y: y}
        }, i) do
    x1 = x + r * :math.cos(i * a)
    y1 = y + r * :math.sin(i * a)
    {Float.round(x1, 2), Float.round(y1, 2)}
  end

  @doc """
  Translate a polygon in cartesian space.

  ## Examples
  iex(1)> p = Collision.two_dimensional_polygon(4, 3, 0, {0,0})
  %Collision.Polygon.RegularPolygon{midpoint: %Collision.Polygon.Vertex{x: 0, y: 0},
  n_sides: 4, radius: 3, rotation_angle: 0.0}
  iex(2)> Collision.Polygon.RegularPolygon.calculate_vertices(p)
  [{3.0, 0.0}, {0.0, 3.0}, {-3.0, 0.0}, {0.0, -3.0}]
  iex(3)> Collision.Polygon.RegularPolygon.translate_polygon(p, %{x: -2, y: +2})
  [{1.0, 2.0}, {-2.0, 5.0}, {-5.0, 2.0}, {-2.0, -1.0}]
  """
  @spec translate_polygon([Vertex.t] | RegularPolygon.t, Vertex.t) :: [Vertex.t]
  def translate_polygon(%RegularPolygon{} = p, %{x: _x, y: _y} = c) do
    polygon_vertices = calculate_vertices(p)
    translate_polygon(polygon_vertices, c)
  end
  def translate_polygon(polygon_vertices, %{x: _x, y: _y} = translation) do
    Enum.map(polygon_vertices, translate_vertex(translation))
  end
  defp translate_vertex(%{x: x_translate, y: y_translate}) do
    fn {x, y} -> {x + x_translate, y + y_translate} end
  end

  # TODO the api around rotation is ugly
  @doc """
  Rotate a regular polygon using rotation angle in degrees.

  ## Examples
  iex(1)> p = Collision.two_dimensional_polygon(4, 3, 0, {0,0})
  %Collision.Polygon.RegularPolygon{midpoint: %Collision.Polygon.Vertex{x: 0,
  y: 0}, n_sides: 4, radius: 3, rotation_angle: 0.0}
  iex(2)> Collision.Polygon.RegularPolygon.calculate_vertices(p)
  [{3.0, 0.0}, {0.0, 3.0}, {-3.0, 0.0}, {0.0, -3.0}]
  iex(3)> Collision.Polygon.RegularPolygon.rotate_polygon_degrees(p, 180)
  [{-3.0, 0.0}, {0.0, -3.0}, {3.0, 0.0}, {0.0, 3.0}]
  iex(4)> Collision.Polygon.RegularPolygon.rotate_polygon_degrees(p, 360)
  [{3.0, 0.0}, {0.0, 3.0}, {-3.0, 0.0}, {0.0, -3.0}]
  """
  @spec rotate_polygon_degrees([Vertex.t] | RegularPolygon.t, degrees) :: [Vertex.t]
  def rotate_polygon_degrees(vertices, degrees) do
    angle_in_radians = Helper.degrees_to_radians(degrees)
    rotate_polygon(vertices, angle_in_radians)
  end

  @doc """
  Rotate a regular polygon, rotation angle should be radians.

  ## Examples
  iex(1)> p = Collision.two_dimensional_polygon(4, 3, 0, {0,0})
  %Collision.Polygon.RegularPolygon{midpoint: %Collision.Polygon.Vertex{x: 0,
  y: 0}, n_sides: 4, radius: 3, rotation_angle: 0.0}
  iex(2)> Collision.Polygon.RegularPolygon.rotate_polygon(p, 3.14)
  [{-3.0, 0.0}, {0.0, -3.0}, {3.0, 0.0}, {0.0, 3.0}]
  """
  @spec rotate_polygon([Vertex.t] | RegularPolygon.t, radians) :: [Vertex.t]
  def rotate_polygon(%RegularPolygon{} = p, radians) do
    p
    |> translate_polygon(%{x: -p.midpoint.x, y: -p.midpoint.y})
    |> rotate_polygon(radians)
    |> translate_polygon(p.midpoint)
  end
  def rotate_polygon(vertices, radians) do
    rotated = fn {x, y} ->
      x_term = x * :math.cos(radians) - y * :math.sin(radians)
      y_term = x * :math.sin(radians) + y * :math.cos(radians)
      {Float.round(x_term, 2), Float.round(y_term, 2)}
    end
    Enum.map(vertices, fn vertex -> rotated.(vertex) end)
  end

  @doc """
  Rounds the x and y components of an {x, y} tuple.

  ## Examples
  iex> Collision.Polygon.RegularPolygon.round_vertices([{1.55555555, 1.2222222}])
  [{1.55556, 1.22222}]
  """
  @spec round_vertices([{number, number}]) :: [{number, number}]
  def round_vertices(vertices) do
    vertices
    |> Enum.map(fn {x, y} ->
      {Float.round(x, 5), Float.round(y, 5)}
    end)
  end
end
