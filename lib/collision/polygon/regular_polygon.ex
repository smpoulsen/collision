defmodule Collision.Polygon.RegularPolygon do
  @moduledoc """
  A regular polygon is equiangular and equilateral -- all
  angles and all sides be equal. With enough sides,
  a regular polygon tends toward a circle.
  """
  defstruct n_sides: 3, radius: 0, rotation_angle: 0.0, midpoint: %{x: 0, y: 0}

  alias Collision.Polygon.RegularPolygon
  alias Collision.Polygon.Helper
  alias Collision.Polygon.Vertex
  alias Collision.SeparatingAxis
  alias Collision.Vector.Vector2

  @typedoc """
  A regular polygon is defined by a number of sides, a circumradius,
  a rotation angle, and a center point `{x, y}`.
  """
  @type t :: Collision.Polygon.RegularPolygon.t
  @type axis :: {Vertex.t, Vertex.t}
  @typep degrees :: number
  @typep radians :: number

  @doc """
  Construct a regular polygon from a tuple.

  A polygon must have at least three sides.

  ## Examples

    iex> Collision.Polygon.RegularPolygon.from_tuple({3, 2, 0, {0, 0}})
    {:ok, %Collision.Polygon.RegularPolygon{n_sides: 3, radius: 2,
    rotation_angle: 0.0, midpoint: %Collision.Polygon.Vertex{x: 0, y: 0}}}

  """
  @spec from_tuple({integer, number, number, {number, number}}, atom) :: RegularPolygon.t
  def from_tuple({s, _r, _a, {_x, _y}}, _d) when s < 3 do
    {:error, "Polygon must have at least three sides"}
  end
  def from_tuple({s, r, a, {x, y}}, :degrees) do
    angle_in_radians = Float.round(Helper.degrees_to_radians(a), 5)
    from_tuple({s, r, angle_in_radians, {x, y}}, :radians)
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

  ## Examples

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
    0..s - 1
    |> Enum.map(fn (n) ->
      calculate_vertex(polygon, rotation_angle, n)
    end)
    |> rotate_polygon(a, polygon.midpoint)
  end

  # Find the vertex of a side of a regular polygon given the polygon struct
  # and an integer representing a side.
  @spec calculate_vertex(RegularPolygon.t, number, integer) :: Vertex.t
  defp calculate_vertex(
        %RegularPolygon{
          radius: r,
          midpoint: %{x: x, y: y}
        }, angle, i) do
    x1 = x + r * :math.cos(i * angle)
    y1 = y + r * :math.sin(i * angle)
    {x1, y1}
  end

  @doc """
  Translate a polygon in cartesian space.

  """
  @spec translate_polygon([Vertex.t] | RegularPolygon.t, Vertex.t) :: [Vertex.t] | RegularPolygon.t
  def translate_polygon(%RegularPolygon{} = p, %{x: _x, y: _y} = c) do
    new_midpoint = translate_midpoint(c).(p.midpoint)
    %{p | midpoint: new_midpoint}
  end
  defp translate_midpoint(%{x: x_translate, y: y_translate}) do
    fn %{x: x, y: y} -> %Vertex{x: x + x_translate, y: y + y_translate} end
  end


  @doc """
  Translate a polygon's vertices.

  ## Examples

    iex(1)> p = Collision.two_dimensional_polygon(4, 3, 0, {0,0})
    %Collision.Polygon.RegularPolygon{midpoint: %Collision.Polygon.Vertex{x: 0, y: 0},
    n_sides: 4, radius: 3, rotation_angle: 0.0}
    iex(2)> Collision.Polygon.RegularPolygon.translate_polygon(p, %{x: -2, y: 2})
    %Collision.Polygon.RegularPolygon{midpoint: %Collision.Polygon.Vertex{x: -2, y: 2},
    n_sides: 4, radius: 3, rotation_angle: 0.0}

  """
  def translate_vertices(polygon_vertices, %{x: _x, y: _y} = translation) do
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
    iex(2)> vertices = Collision.Polygon.RegularPolygon.calculate_vertices(p)
    [{3.0, 0.0}, {0.0, 3.0}, {-3.0, 0.0}, {0.0, -3.0}]
    iex(3)> Collision.Polygon.RegularPolygon.rotate_polygon_degrees(vertices, 180)
    [{-3.0, 0.0}, {0.0, -3.0}, {3.0, 0.0}, {0.0, 3.0}]
    iex(4)> Collision.Polygon.RegularPolygon.rotate_polygon_degrees(vertices, 360)
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
    iex(2)> v = Collision.Polygon.RegularPolygon.calculate_vertices(p)
    iex(3)> Collision.Polygon.RegularPolygon.rotate_polygon(v, 3.14)
    [{-3.0, 0.0}, {0.0, -3.0}, {3.0, 0.0}, {0.0, 3.0}]

  """
  @spec rotate_polygon([Vertex.t], radians, %{x: number, y: number}) :: [Vertex.t]
  def rotate_polygon(vertices, radians, rotation_point \\ %{x: 0, y: 0}) do
    rotated = fn {x, y} ->
      x_offset = x - rotation_point.x
      y_offset = y - rotation_point.y
      x_term = rotation_point.x + (x_offset * :math.cos(radians) - y_offset * :math.sin(radians))
      y_term = rotation_point.y + (x_offset * :math.sin(radians) + y_offset * :math.cos(radians))
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

  defimpl String.Chars, for: RegularPolygon do
    def to_string(%RegularPolygon{} = p) do
      "%RegularPolygon{
        n_sides: #{p.n_sides}, radius: #{p.radius},
        rotation_angle: #{p.rotation_angle},
        midpoint: %{x: #{p.midpoint.x}, y: #{p.midpoint.y}}
      }"
    end
  end

  defimpl Collidable, for: RegularPolygon do
    def collision?(polygon1, polygon2) do
      p1_vertices = RegularPolygon.calculate_vertices(polygon1)
      p2_vertices = RegularPolygon.calculate_vertices(polygon2)
      SeparatingAxis.collision?(p1_vertices, p2_vertices)
    end

    def resolution(%RegularPolygon{} = p1, %RegularPolygon{} = p2) do
      p1_vertices = RegularPolygon.calculate_vertices(p1)
      p2_vertices = RegularPolygon.calculate_vertices(p2)
      SeparatingAxis.collision_mtv(p1_vertices, p2_vertices)
    end

    @spec resolve_collision(RegularPolygon.t, RegularPolygon.t) :: {RegularPolygon.t, RegularPolygon.t}
    def resolve_collision(%RegularPolygon{} = p1, %RegularPolygon{} = p2) do
      {mtv, magnitude} = resolution(p1, p2)
      vector_from_p1_to_p2 = %Vector2{
        x: p2.midpoint.x - p1.midpoint.x,
        y: p2.midpoint.y - p1.midpoint.y}
      translation_vector =
        case Vector.dot_product(mtv, vector_from_p1_to_p2) do
          x when x < 0 ->
            Vector.scalar_mult(mtv, -1 * magnitude)
          _ ->
            Vector.scalar_mult(mtv, magnitude)
        end
      {p1, RegularPolygon.translate_polygon(p2, translation_vector)}
    end
  end
end
