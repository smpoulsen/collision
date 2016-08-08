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

  def rotate_polygon_degrees(%RegularPolygon{} = p, degrees) do
    rotated_polygon = Polygon.rotate_polygon_degrees(p.polygon, degrees, p.midpoint)
    %{p | polygon: rotated_polygon}
  end
  def rotate_polygon(%RegularPolygon{} = p, radians) do
    rotated_polygon = Polygon.rotate_polygon(p.polygon, radians, p.midpoint)
    %{p | polygon: rotated_polygon}
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
