defmodule Collision.SeparatingAxis do
  @moduledoc """
  Implements the separating axis theorem for collision detection.

  Checks for collision by projecting all of the edges of a polygon
  against test axes, which are the normals of all the edges of
  both polygons that are being tested.

  If there is any axis for which the projections aren't overlapping,
  then the polygons are not colliding with one another. If all of
  the axes have overlapping projections, the polygons are colliding.
  """

  alias Collision.Polygon.Vertex
  alias Collision.Polygon.RegularPolygon
  alias Collision.Vector.Vector2

  @type axis :: {Vertex.t, Vertex.t}
  @type polygon :: RegularPolygon.t

  @doc """
  Check for collision between two polygons.

  Returns: true | false

  ## Examples
    iex> SeparatingAxis.collision?(
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2, midpoint: %{x: 4, y: 4}}
    ...> )
    false

    iex> Collision.SeparatingAxis.collision?(
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 4,
    ...>     midpoint: %{x: 4, y: 2}}
    ...> )
    true
  """
  @spec collision?(polygon, polygon) :: boolean
  def collision?(%RegularPolygon{} = p1, %RegularPolygon{} = p2) do
    p1_vertices = RegularPolygon.calculate_vertices(p1)
    p2_vertices = RegularPolygon.calculate_vertices(p2)
    collision?(p1_vertices, p2_vertices)
  end
  def collision?(p1, p2) do
    projections = collision_projections(p1, p2)
    Enum.all?(projections, fn zipped_projection ->
      overlap?(zipped_projection) || containment?(zipped_projection)
    end)
  end

  @doc """
  Checks for collision between two polygons and, if colliding, calculates
  the minimum translation vector to move out of collision. The float in the
  return is the magnitude of overlap?.

  Returns: nil | {%Vector2{}, float}

  ## Examples
    iex> Collision.SeparatingAxis.collision_mtv(
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2, midpoint: %{x: 4, y: 4}}
    ...> )
    nil

    iex> Collision.SeparatingAxis.collision_mtv(
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 4,
    ...>     midpoint: %{x: 4, y: 1}}
    ...> )
    {%Collision.Vector.Vector2{x: 2.0, y: 2.0}, 2.0}
  """
  # TODO There is repetition between this and collision?, but it
  # runs faster this way. Refactoring opportunity in the future.
  @spec collision_mtv(polygon, polygon) :: {Vector2.t, number}
  def collision_mtv(%RegularPolygon{} = p1, %RegularPolygon{} = p2) do
    p1_vertices = RegularPolygon.calculate_vertices(p1)
    p2_vertices = RegularPolygon.calculate_vertices(p2)
    collision_mtv(p1_vertices, p2_vertices)
  end
  def collision_mtv(p1, p2) do
    axes_to_test = test_axes(p1) ++ test_axes(p2)
    zipped_projections = collision_projections(p1, p2)
    axes_and_projections = Enum.zip(axes_to_test, zipped_projections)
    in_collision = axes_and_projections
    |> Enum.all?(fn {_axis, zipped_projection} ->
      overlap?(zipped_projection) || containment?(zipped_projection)
    end)
    if in_collision do
      axes_and_projections
      |> Enum.filter(fn {_axis, projection} ->
        overlap?(projection) || containment?(projection)
      end)
      |> minimum_overlap
    end
  end

  # Get the axes to project the polygons against.
  # The list of vertices is expected to be ordered counter-clockwise,
  # so we're using the left normal to generate test axes.
  @spec test_axes([Vertex.t] | polygon) :: [axis]
  defp test_axes(vertices) do
    vertices
    |> Stream.chunk(2, 1, [Enum.at(vertices, 0)])
    |> Stream.map(fn [a, b] -> Vector2.from_points(a,b) end)
    |> Enum.map(&(Vector2.left_normal(&1)))
    |> Enum.map(&(Vector.normalize(&1)))
  end

  # Project all of a polygon's edges onto the test axis and return
  # the minimum and maximum points.
  #@spec project_onto_axis([Vertex.t], Vertex.t) :: (number, number)
  defp project_onto_axis(vertices, axis) do
    dot_products = vertices
    |> Enum.map(fn vertex ->
      vertex
      |> Collision.Vector.from_tuple
      |> Vector.dot_product(axis)
    end)
    {Enum.min(dot_products), Enum.max(dot_products)}
  end

  # Given a polygon, project all of its edges onto an axis.
  @spec project_onto_axes(polygon, [Vector2.t]) :: [Vector2.t]
  defp project_onto_axes(polygon, axes) do
    Enum.map(axes, fn axis ->
      project_onto_axis(polygon, axis)
    end)
  end

  # Check whether a pair of lines are overlapping.
  @spec overlap?(axis) :: boolean
  defp overlap?({{min1, max1}, {min2, max2}}) do
    !((min1 > max2) || (min2 > max1))
  end

  # Check whether a line is wholly contained within another.
  @spec containment?(axis) :: boolean
  def containment?({{min1, max1}, {min2, max2}}) do
    line1_inside = min1 > min2 && max1 < max2
    line2_inside = min2 > min1 && max2 < max1
    line1_inside || line2_inside
  end
  # Calculate the magnitude of overlap for overlapping lines.
  @spec overlap_magnitude(axis) :: number
  def overlap_magnitude({{min1, max1}, {min2, max2}}) do
    min(max1 - min2, max2 - min1)
  end

  # Given a list of vector/axis tuples, finds the minimum translation
  # vector and magnitude to move the polygons out of collision.
  @spec minimum_overlap([{Vector2.t, axis}]) :: {Vector2.t, number}
  def minimum_overlap(axes) do
    axes
    |> Stream.map(fn {v, a} -> {v, overlap_magnitude(a)} end)
    |> Enum.sort_by(fn {_v, a} -> a end)
    |> Enum.at(0)
  end

  # Generate a zipped list of projections for both polygons.
  @spec collision_projections(polygon, polygon) :: [{Vector2.t, Vector2.t}]
  defp collision_projections(p1, p2) do
    axes_to_test = test_axes(p1) ++ test_axes(p2)
    p1_projection = project_onto_axes(p1, axes_to_test)
    p2_projection = project_onto_axes(p2, axes_to_test)
    Enum.zip(p1_projection, p2_projection)
  end
end
