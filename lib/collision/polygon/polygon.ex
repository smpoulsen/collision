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
  alias Collision.Vector.Vector2
  alias Collision.Detection.SeparatingAxis

  @type t :: %Polygon{edges: [Edge.t]}
  @type axis :: {Vertex.t, Vertex.t}
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
  Construct a regular polygon.

  A polygon must have at least three sides.

  ## Examples

  """
  @spec gen_regular_polygon(integer, number, number, {number, number}, atom) :: Polygon.t
  def gen_regular_polygon(s, _r, _a, {_x, _y}, _d) when s < 3 do
    {:error, "Polygon must have at least three sides"}
  end
  def gen_regular_polygon(s, r, a, {x, y}, :degrees) do
    angle_in_radians = Float.round(Helper.degrees_to_radians(a), 5)
    gen_regular_polygon(s, r, angle_in_radians, {x, y}, :radians)
  end
  def gen_regular_polygon(s, r, a, {x, y}, :radians) do
    vertices = calculate_vertices(s, r, a, %{x: x, y: y})
    Polygon.from_vertices(vertices)
  end
  def gen_regular_polygon(s, r, a, {x, y}), do: gen_regular_polygon(s, r, a, {x, y}, :degrees)

  @doc """
  Determine the vertices, or points, of the polygon.

  ## Examples


  """
  @spec calculate_vertices(t | number, number, %{x: number, y: number}) :: [Vertex.t]
  defp calculate_vertices(sides, _r, _a, _m) when sides < 3, do: {:invalid_number_of_sides}
  defp calculate_vertices(sides, radius, initial_rotation_angle, midpoint \\ %{x: 0, y: 0}) do
    rotation_angle = 2 * :math.pi / sides
    f_rotate_vertex = Polygon.rotate_vertex(initial_rotation_angle, midpoint)
    0..sides - 1
    |> Stream.map(fn (n) ->
      calculate_vertex(radius, midpoint, rotation_angle, n)
    end)
    |> Stream.map(fn vertex -> f_rotate_vertex.(vertex) end)
    |> Enum.map(&Vertex.round_vertex/1)
  end
  # Find the vertex of a side of a regular polygon from its number of sides and the
  # angle between its vertices.
  @spec calculate_vertex(number, %{x: number, y: number}, number, integer) :: Vertex.t
  defp calculate_vertex(radius, %{x: x, y: y} = midpoint , angle, i) do
    x1 = x + radius * :math.cos(i * angle)
    y1 = y + radius * :math.sin(i * angle)
    %Vertex{x: x1, y: y1}
  end

  @doc """
  In a convex polygon, all internal angles are < 180 degrees.

  Returns: true | false

  ## Example

    iex> p = Polygon.from_vertices([%Vertex{x: 2, y: 2}, %Vertex{x: -2, y: 2},
    ...>     %Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2}])
    iex> Polygon.convex?(p)
    true

    iex> p = Polygon.from_vertices([%Vertex{x: 2, y: 2}, %Vertex{x: 0, y: 0},
    ...>     %Vertex{x: -2, y: 2}, %Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2}])
    iex> Polygon.convex?(p)
    false
  """
  @spec convex?(Polygon.t) :: boolean
  def convex?(%Polygon{edges: edges}) do
    edges
    |> Stream.cycle
    |> Stream.chunk(3, 1)
    |> Stream.take(length(edges))
    |> Stream.map(&Edge.calculate_angle/1)
    |> Enum.all?(&(&1 < :math.pi))
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

  @spec centroid(Polygon.t) :: Vertex.t
  def centroid(%Polygon{} = polygon) do
    polygon.vertices
    |> Enum.reduce({0, 0}, fn vertex, {x, y} ->
      {x + vertex.x, y + vertex.y}
    end)
    |> (fn {x, y} ->
      {x / length(polygon.vertices), y / length(polygon.vertices)}
    end).()
    |> Vertex.from_tuple
  end

  @doc """
  Rotate a regular polygon using rotation angle in degrees.

  ## Examples

  """
  @spec rotate_polygon_degrees(Polygon.t, degrees, %{x: number, y: number}) :: Polygon.t
  def rotate_polygon_degrees(polygon, degrees, point \\ %{x: 0, y: 0}) do
    angle_in_radians = Helper.degrees_to_radians(degrees)
    rotate_polygon(polygon, angle_in_radians, point)
  end

  @doc """
  Rotate a polygon, rotation angle should be radians.

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

  @spec rotate_vertex(number, Vertex.t) :: Vertex.t
  def rotate_vertex(radians, rotation_point) do
    fn %{x: x, y: y} ->
      x_offset = x - rotation_point.x
      y_offset = y - rotation_point.y
      x_term = rotation_point.x + (x_offset * :math.cos(radians) - y_offset * :math.sin(radians))
      y_term = rotation_point.y + (x_offset * :math.sin(radians) + y_offset * :math.cos(radians))
      %Vertex{x: x_term, y: y_term}
    end
  end

  defimpl String.Chars, for: Polygon do
    @spec to_string(Polygon.t) :: String.t
    def to_string(%Polygon{} = p) do
      edges = Enum.map(p.edges, &String.Chars.to_string/1)
      "#{Enum.join(edges, ",")}"
    end
  end

  defimpl Collidable, for: Polygon do
    @spec collision?(Polygon.t, Polygon.t) :: boolean
    def collision?(%Polygon{} = p1, %Polygon{} = p2) do
      SeparatingAxis.collision?(p1, p2)
    end

    @spec resolution(Polygon.t, Polygon.t) :: {Vector2.t, number}
    def resolution(%Polygon{} = p1, %Polygon{} = p2) do
      SeparatingAxis.collision_mtv(p1, p2)
    end

    @spec resolve_collision(Polygon.t, Polygon.t) :: {Polygon.t, Polygon.t}
    def resolve_collision(%Polygon{} = p1, %Polygon{} = p2) do
      {mtv, magnitude} = resolution(p1, p2)
      p1_midpoint = Polygon.centroid(p1)
      p2_midpoint = Polygon.centroid(p2)
      vector_from_p1_to_p2 = %Vector2{
        x: p2_midpoint.x - p1_midpoint.x,
        y: p2_midpoint.y - p1_midpoint.y}
      translation_vector =
        case Vector.dot_product(mtv, vector_from_p1_to_p2) do
          x when x < 0 ->
            Vector.scalar_mult(mtv, -1 * magnitude)
          _ ->
            Vector.scalar_mult(mtv, magnitude)
        end
      translated = Polygon.translate_polygon(p2, translation_vector)
      translated_mtv = Collidable.resolution(p1, translated)
      # TODO This is a workaround. There's something wrong with the calculation
      # for vector_from_p1_to_p2 that's causing the translation vector to be
      # flipped in cases of (near total) containment.
      case translated_mtv do
        nil -> {p1, Polygon.translate_polygon(p2, translation_vector)}
        {_mtv, magnitude} ->
          if round(magnitude) == 0 do
            {p1, Polygon.translate_polygon(p2, translation_vector)}
          else
            opposite_translation = Vector.scalar_mult(translation_vector, -1)
            {p1, Polygon.translate_polygon(p2, opposite_translation)}
          end
      end
    end
  end
end
