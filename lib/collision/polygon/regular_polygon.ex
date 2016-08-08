defmodule Collision.Polygon.RegularPolygon do
  @moduledoc """
  A regular polygon is equiangular and equilateral -- all
  angles and all sides be equal. With enough sides,
  a regular polygon tends toward a circle.
  """
  defstruct sides: 3, radius: 0, rotation_angle: 0.0, midpoint: %{x: 0, y: 0}, polygon: nil

  alias Collision.Polygon.RegularPolygon
  alias Collision.Polygon
  alias Collision.Polygon.Helper
  alias Collision.Polygon.Vertex
  alias Collision.Polygon.Edge
  alias Collision.Detection.SeparatingAxis
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
    vertices = calculate_vertices(s, r, a, %{x: x, y: y})
    polygon = Polygon.from_vertices(vertices)
    {:ok,
     %RegularPolygon{
       sides: s,
       radius: r,
       rotation_angle: a,
       midpoint: %Vertex{x: x, y: y},
       polygon: polygon
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
  @spec calculate_vertices(t | number, number, %{x: number, y: number}) :: [Vertex.t]
  def calculate_vertices(%RegularPolygon{} = p) do
    calculate_vertices(p.sides, p.radius, p.rotation_angle, p.midpoint)
  end
  def calculate_vertices(sides, _r, _a, _m) when sides < 3, do: {:invalid_number_of_sides}
  def calculate_vertices(sides, radius, initial_rotation_angle, midpoint \\ %{x: 0, y: 0}) do
    rotation_angle = 2 * :math.pi / sides
    f_rotate_vertex = Polygon.rotate_vertex(initial_rotation_angle, midpoint)
    0..sides - 1
    |> Stream.map(fn (n) ->
      calculate_vertex(radius, midpoint, rotation_angle, n)
    end)
    |> Stream.map(fn vertex -> f_rotate_vertex.(vertex) end)
    |> Enum.map(&Vertex.round_vertex/1)
  end

  # Find the vertex of a side of a regular polygon given the polygon struct
  # and an integer representing a side.
  @spec calculate_vertex(number, %{x: number, y: number}, number, integer) :: Vertex.t
  defp calculate_vertex(radius, %{x: x, y: y} = midpoint , angle, i) do
    x1 = x + radius * :math.cos(i * angle)
    y1 = y + radius * :math.sin(i * angle)
    %Vertex{x: x1, y: y1}
  end

  @doc """
  Translate a polygon in cartesian space.

  """
  @spec translate_polygon([Vertex.t] | RegularPolygon.t, Vertex.t) :: [Vertex.t] | RegularPolygon.t
  def translate_polygon(%RegularPolygon{} = p, %{x: _x, y: _y} = c) do
    new_midpoint = translate_midpoint(c).(p.midpoint)
    new_vertices = calculate_vertices(
      p.sides, p.radius, p.rotation_angle, new_midpoint
    )
    %{p | midpoint: new_midpoint, polygon: Polygon.from_vertices(new_vertices)}
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
      "%RegularPolygon{sides: #{p.sides}, radius: #{p.radius}, " <>
      "midpoint #{p.midpoint}, edges: #{p.polygon.edges}, " <>
      "vertices: #{p.polygon.vertices}"
    end
  end

  defimpl Collidable, for: RegularPolygon do
    @spec collision?(RegularPolygon.t, RegularPolygon.t) :: boolean
    def collision?(p1, p2) do
      SeparatingAxis.collision?(p1.polygon.vertices, p2.polygon.vertices)
    end

    def resolution(%RegularPolygon{} = p1, %RegularPolygon{} = p2) do
      SeparatingAxis.collision_mtv(p1.polygon, p2.polygon)
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
