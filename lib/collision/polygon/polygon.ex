defmodule Collision.Polygon do
  @moduledoc """
  A general polygon is defined by its vertices; from these we can calculate
  the edges, centroid, rotation angles, and whether the polygon is concave
  or convex.
  """
  defstruct edges: [], vertices: [], convex: true

  alias Collision.Detection.SeparatingAxis
  alias Collision.Polygon
  alias Collision.Polygon.Edge
  alias Collision.Polygon.Helper
  alias Collision.Polygon.Vertex
  alias Collision.Vector.Vector2

  @type t :: %Polygon{edges: [Edge.t]}
  @type axis :: {Vertex.t, Vertex.t}
  @typep degrees :: number
  @typep radians :: number

  @doc """
  Takes a list of ordered vertices and returns the polygon they describe.

  Returns: %Polygon{}

  ## Example

      iex> Polygon.from_vertices([
      ...>   %Vertex{x: 4, y: 4}, %Vertex{x: 0, y: 4},
      ...>   %Vertex{x: 0, y: 0}, %Vertex{x: 4, y: 0}])
      %Polygon{vertices: [
        %Vertex{x: 4, y: 4}, %Vertex{x: 0, y: 4},
        %Vertex{x: 0, y: 0}, %Vertex{x: 4, y: 0}
      ], edges: [
        %Edge{length: 4.0, next: %Vertex{x: 0, y: 4}, point: %Vertex{x: 4, y: 4}},
        %Edge{length: 4.0, next: %Vertex{x: 0, y: 0}, point: %Vertex{x: 0, y: 4}},
        %Edge{length: 4.0, next: %Vertex{x: 4, y: 0}, point: %Vertex{x: 0, y: 0}},
        %Edge{length: 4.0, next: %Vertex{x: 4, y: 4}, point: %Vertex{x: 4, y: 0}}
      ]}

  """
  @spec from_vertices([Vertex.t]) :: t
  def from_vertices(vertices) do
    edges = vertices
    |> Stream.chunk(2, 1, [Enum.at(vertices, 0)])
    |> Enum.map(fn [point1, point2] ->
      Edge.from_vertex_pair({point1, point2})
    end)
    convex = convex?(edges)
    %Polygon{edges: edges, vertices: vertices, convex: convex}
  end

  @doc """
  Construct a regular polygon.

  A polygon must have at least three sides.

  ## Examples

      iex> Polygon.gen_regular_polygon(4, 4, 0, {0, 0})
      %Polygon{vertices: [
        %Vertex{x: 4.0, y: 0.0}, %Vertex{x: 0.0, y: 4.0},
        %Vertex{x: -4.0, y: 0.0}, %Vertex{x: 0.0, y: -4.0}
      ], edges: [
        %Edge{length: 5.656854249492381, next: %Vertex{x: 0.0, y: 4.0}, point: %Vertex{x: 4.0, y: 0.0}},
        %Edge{length: 5.656854249492381, next: %Vertex{x: -4.0, y: 0.0}, point: %Vertex{x: 0.0, y: 4.0}},
        %Edge{length: 5.656854249492381, next: %Vertex{x: 0.0, y: -4.0}, point: %Vertex{x: -4.0, y: 0.0}},
        %Edge{length: 5.656854249492381, next: %Vertex{x: 4.0, y: 0.0}, point: %Vertex{x: 0.0, y: -4.0}}
      ]}

      iex> Polygon.gen_regular_polygon(3, 2, 0, {0, 0})
      %Polygon{edges: [
        %Edge{length: 3.4641012113533867, next: %Vertex{x: -1.0, y: 1.73205}, point: %Vertex{x: 2.0, y: 0.0}},
        %Edge{length: 3.4641, next: %Vertex{x: -1.0, y: -1.73205}, point: %Vertex{x: -1.0, y: 1.73205}},
        %Edge{length: 3.4641012113533867, next: %Vertex{x: 2.0, y: 0.0}, point: %Vertex{x: -1.0, y: -1.73205}}
      ], vertices: [
        %Vertex{x: 2.0, y: 0.0},
        %Vertex{x: -1.0, y: 1.73205},
        %Vertex{x: -1.0, y: -1.73205}
      ]}

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

  # Calculate the vertices of a regular polygon.
  @spec calculate_vertices(number, number, number, %{x: number, y: number}) :: [Vertex.t]
  defp calculate_vertices(sides, _r, _a, _m) when sides < 3, do: {:invalid_number_of_sides}
  defp calculate_vertices(sides, radius, initial_rotation_angle, midpoint) do
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
  defp calculate_vertex(radius, %{x: x, y: y} = _midpoint , angle, i) do
    x1 = x + radius * :math.cos(i * angle)
    y1 = y + radius * :math.sin(i * angle)
    %Vertex{x: x1, y: y1}
  end

  @doc """
  In a convex polygon, all internal angles are < 180 degrees.

  Returns: true | false

  ## Example

    iex> p = Polygon.from_vertices([
    ...>       %Vertex{x: 2, y: 2}, %Vertex{x: -2, y: 2},
    ...>       %Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2}
    ...>     ])
    iex> Polygon.convex?(p)
    true

    iex> p = Polygon.from_vertices([%Vertex{x: 2, y: 2}, %Vertex{x: 0, y: 0},
    ...>     %Vertex{x: -2, y: 2}, %Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2}])
    iex> Polygon.convex?(p)
    false

  """
  @spec convex?(Polygon.t | [Edge.t]) :: boolean
  def convex?(%Polygon{edges: edges}), do: convex?(edges)
  def convex?(edges) do
    edges
    |> Stream.cycle
    |> Stream.chunk(2, 1)
    |> Stream.take(length(edges))
    |> Stream.map(&Edge.calculate_angle/1)
    |> Enum.all?(&(&1 <= :math.pi))
  end

  @doc """
  Translate a polygon's vertices.

  Returns: %Polygon{}

  ## Example

      iex> p = Polygon.gen_regular_polygon(4, 4, 0, {0, 0})
      iex> Polygon.translate(p, %{x: 2, y: 2})
      %Polygon{vertices: [
        %Vertex{x: 6.0, y: 2.0}, %Vertex{x: 2.0, y: 6.0},
        %Vertex{x: -2.0, y: 2.0}, %Vertex{x: 2.0, y: -2.0}
      ], edges: [
        %Edge{length: 5.656854249492381, next: %Vertex{x: 2.0, y: 6.0}, point: %Vertex{x: 6.0, y: 2.0}},
        %Edge{length: 5.656854249492381, next: %Vertex{x: -2.0, y: 2.0}, point: %Vertex{x: 2.0, y: 6.0}},
        %Edge{length: 5.656854249492381, next: %Vertex{x: 2.0, y: -2.0}, point: %Vertex{x: -2.0, y: 2.0}},
        %Edge{length: 5.656854249492381, next: %Vertex{x: 6.0, y: 2.0}, point: %Vertex{x: 2.0, y: -2.0}}
      ]}

  """
  @spec translate(Polygon.t, %{x: number, y: number}) :: Polygon.t
  def translate(polygon, %{x: _x, y: _y} = translation_vector) do
    polygon.vertices
    |> Enum.map(translate_vertex(translation_vector))
    |> Enum.map(&Vertex.round_vertex/1)
    |> from_vertices
  end
  defp translate_vertex(%{x: x_translate, y: y_translate}) do
    fn %{x: x, y: y} -> %Vertex{x: x + x_translate, y: y + y_translate} end
  end

  @doc """
  Find the midpoint of a polygon.

  Returns: %Vertex{}

  ## Example

      iex> p = Polygon.gen_regular_polygon(4, 4, 0, {0, 0})
      iex> Polygon.centroid(p)
      %Vertex{x: 0.0, y: 0.0}

  """
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

  Returns: %Polygon{}

  ## Example

      iex> p = Polygon.from_vertices([
      ...>       %Vertex{x: 2, y: 2}, %Vertex{x: -2, y: 2},
      ...>       %Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2}
      ...>     ])
      iex> Polygon.rotate_degrees(p, 90)
      %Polygon{edges: [
        %Edge{length: 4.0, next: %Vertex{x: -2.0, y: -2.0}, point: %Vertex{x: -2.0, y: 2.0}},
        %Edge{length: 4.0, next: %Vertex{x: 2.0, y: -2.0}, point: %Vertex{x: -2.0, y: -2.0}},
        %Edge{length: 4.0, next: %Vertex{x: 2.0, y: 2.0}, point: %Vertex{x: 2.0, y: -2.0}},
        %Edge{length: 4.0, next: %Vertex{x: -2.0, y: 2.0}, point: %Vertex{x: 2.0, y: 2.0}}
      ], vertices: [
        %Vertex{x: -2.0, y: 2.0}, %Vertex{x: -2.0, y: -2.0},
        %Vertex{x: 2.0, y: -2.0}, %Vertex{x: 2.0, y: 2.0}
      ]}

  """
  @spec rotate_degrees(Polygon.t, degrees, %{x: number, y: number}) :: Polygon.t
  def rotate_degrees(polygon, degrees, point \\ %{x: 0, y: 0}) do
    angle_in_radians = Helper.degrees_to_radians(degrees)
    rotate(polygon, angle_in_radians, point)
  end

  @doc """
  Rotate a polygon, rotation angle should be radians.

  The rotation point is the point around which the polygon is rotated.
  It defaults to the origin, so without specifying the polygon's
  centroid as the rotation point, it will not be an in-place rotation.

  Returns: %Polygon{}

  ## Example

      iex> p = Polygon.from_vertices([
      ...>       %Vertex{x: 2, y: 2}, %Vertex{x: -2, y: 2},
      ...>       %Vertex{x: -2, y: -2}, %Vertex{x: 2, y: -2}
      ...>     ])
      iex> Polygon.rotate(p, :math.pi)
      %Polygon{edges: [
      %Edge{length: 4.0, next: %Vertex{x: 2.0, y: -2.0}, point: %Vertex{x: -2.0, y: -2.0}},
      %Edge{length: 4.0, next: %Vertex{x: 2.0, y: 2.0}, point: %Vertex{x: 2.0, y: -2.0}},
        %Edge{length: 4.0, next: %Vertex{x: -2.0, y: 2.0}, point: %Vertex{x: 2.0, y: 2.0}},
        %Edge{length: 4.0, next: %Vertex{x: -2.0, y: -2.0}, point: %Vertex{x: -2.0, y: 2.0}}
      ], vertices: [
        %Vertex{x: -2.0, y: -2.0}, %Vertex{x: 2.0, y: -2.0},
        %Vertex{x: 2.0, y: 2.0}, %Vertex{x: -2.0, y: 2.0}
      ]}

  """
  @spec rotate(Polygon.t, radians, %{x: number, y: number}) :: Polygon.t
  def rotate(polygon, radians, rotation_point \\ %{x: 0, y: 0}) do
    rotate = rotate_vertex(radians, rotation_point)
    polygon.vertices
    |> Enum.map(fn vertex -> rotate.(vertex) end)
    |> from_vertices
  end

  @doc """
  From an angle and a vertex, generates a function to rotate a vertex around
  a point.

  Returns: (%Vertex{} -> %Vertex{})

  ## Example

      iex> rotation = Polygon.rotate_vertex(:math.pi, %{x: 0, y: 0})
      iex> rotation.(%Vertex{x: 5, y: 0})
      %Vertex{x: -5.0, y: 0.0}

  """
  @spec rotate_vertex(radians, Vertex.t) :: (Vertex.t -> Vertex.t)
  def rotate_vertex(radians, rotation_point) do
    fn %{x: x, y: y} ->
      x_offset = x - rotation_point.x
      y_offset = y - rotation_point.y
      x_term = rotation_point.x + (x_offset * :math.cos(radians) - y_offset * :math.sin(radians))
      y_term = rotation_point.y + (x_offset * :math.sin(radians) + y_offset * :math.cos(radians))
      %Vertex{x: Float.round(x_term, 5), y: Float.round(y_term, 5)}
    end
  end

  defimpl String.Chars, for: Polygon do
    def to_string(%Polygon{} = p) do
      edges = Enum.map(p.edges, &String.Chars.to_string/1)
      "#{Enum.join(edges, ",")}"
    end
  end

  defimpl Collidable, for: Polygon do
    def collision?(%Polygon{convex: false} = p1, %Polygon{convex: true} = p2) do
      p1_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p1.vertices))
      collision?(p1_convex_hull, p2)
    end
    def collision?(%Polygon{convex: true} = p1, %Polygon{convex: false} = p2) do
      p2_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p2.vertices))
      collision?(p1, p2_convex_hull)
    end
    def collision?(%Polygon{convex: false} = p1, %Polygon{convex: false} = p2) do
      p1_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p1.vertices))
      p2_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p2.vertices))
      collision?(p1_convex_hull, p2_convex_hull)
    end
    def collision?(%Polygon{} = p1, %Polygon{} = p2) do
      SeparatingAxis.collision?(p1, p2)
    end

    def resolution(%Polygon{convex: false} = p1, %Polygon{convex: true} = p2) do
      p1_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p1.vertices))
      resolution(p1_convex_hull, p2)
    end
    def resolution(%Polygon{convex: true} = p1, %Polygon{convex: false} = p2) do
      p2_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p2.vertices))
      resolution(p1, p2_convex_hull)
    end
    def resolution(%Polygon{convex: false} = p1, %Polygon{convex: false} = p2) do
      p1_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p1.vertices))
      p2_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p2.vertices))
      resolution(p1_convex_hull, p2_convex_hull)
    end
    def resolution(%Polygon{} = p1, %Polygon{} = p2) do
      SeparatingAxis.collision_mtv(p1, p2)
    end

    # TODO Dry this up
    def resolve_collision(%Polygon{convex: false} = p1, %Polygon{convex: true} = p2) do
      p1_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p1.vertices))
      translation_vector = translation(p1_convex_hull, p2)
      translated = Polygon.translate(p2, translation_vector)
      opposite_vector = opposite_translation(translation_vector, p1_convex_hull, translated)
      case opposite_vector do
        x when x == translation_vector -> {p1, translated}
        _ -> {p1, Polygon.translate(p2, opposite_vector)}
      end
    end
    def resolve_collision(%Polygon{convex: true} = p1, %Polygon{convex: false} = p2) do
      p2_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p2.vertices))
      translation_vector = translation(p1, p2_convex_hull)
      translated = Polygon.translate(p2_convex_hull, translation_vector)
      opposite_vector = opposite_translation(translation_vector, p1, translated)
      case opposite_vector do
        x when x == translation_vector -> {p1, Polygon.translate(p2, translation_vector)}
        _ -> {p1, Polygon.translate(p2, opposite_vector)}
      end
    end
    def resolve_collision(%Polygon{convex: false} = p1, %Polygon{convex: false} = p2) do
      p1_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p1.vertices))
      p2_convex_hull = Polygon.from_vertices(Vertex.graham_scan(p2.vertices))
      translation_vector = translation(p1_convex_hull, p2_convex_hull)
      translated = Polygon.translate(p2_convex_hull, translation_vector)
      opposite_vector = opposite_translation(translation_vector, p1_convex_hull, translated)
      case opposite_vector do
        x when x == translation_vector -> {p1, Polygon.translate(p2, translation_vector)}
        _ -> {p1, Polygon.translate(p2, opposite_vector)}
      end
    end
    def resolve_collision(%Polygon{} = p1, %Polygon{} = p2) do
      translation_vector = translation(p1, p2)
      translated = Polygon.translate(p2, translation_vector)
      opposite_vector = opposite_translation(translation_vector, p1, translated)
      case opposite_vector do
        x when x == translation_vector -> {p1, translated}
        _ -> {p1, Polygon.translate(p2, opposite_vector)}
      end
    end
    defp translation(%Polygon{} = p1, %Polygon{} = p2) do
      case resolution(p1, p2) do
        nil -> %Vector2{x: 0, y: 0}
        {mtv, magnitude} ->
          p1_midpoint = Polygon.centroid(p1)
          p2_midpoint = Polygon.centroid(p2)
          vector_from_p1_to_p2 = %Vector2{
            x: p2_midpoint.x - p1_midpoint.x,
            y: p2_midpoint.y - p1_midpoint.y}
          case Vector.dot_product(mtv, vector_from_p1_to_p2) do
            x when x < 0 ->
              Vector.scalar_mult(mtv, magnitude)
            _ ->
              Vector.scalar_mult(mtv, -1 * magnitude)
          end
      end
    end
    defp opposite_translation(translation_vector,
          %Polygon{} = p1, %Polygon{} = translated) do
      translated_mtv = Collidable.resolution(p1, translated)
      # TODO This is a workaround. There's something wrong with the calculation
      # for vector_from_p1_to_p2 that's causing the translation vector to be
      # flipped in cases of (near total) containment.
      case translated_mtv do
        nil -> translation_vector
        {_mtv, magnitude} ->
          if round(magnitude) == 0 do
            translation_vector
          else
            Vector.scalar_mult(translation_vector, -1)
          end
      end
    end
  end
end
