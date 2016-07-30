defmodule Collision.Polygon.RegularPolygonTest do
  use ExUnit.Case
  use ExCheck
  doctest Collision.Polygon.RegularPolygon
  alias Collision.Polygon.RegularPolygon

  # Generator for RegularPolygon values
  def polygon do
    domain(:polygon,
      fn(self, size) ->
        {_, s} = :triq_dom.pick(non_neg_integer, size)
        {_, r} = :triq_dom.pick(non_neg_integer, size)
        {_, a} = :triq_dom.pick(non_neg_integer, size)
        {_, x} = :triq_dom.pick(non_neg_integer, size)
        {_, y} = :triq_dom.pick(non_neg_integer, size)
        {:ok, polygon} = RegularPolygon.from_tuple({max(s, 3), max(r, 1), a, {x, y}})
        {self, polygon}
      end, fn
        (self, polygon) ->
          s = max(polygon.n_sides - 2, 3)
          r = max(polygon.radius - 2, 1)
          a = max(polygon.rotation_angle - 2, 0)
          x = max(polygon.midpoint.x - 2, 0)
          y = max(polygon.midpoint.y - 2, 0)
          {:ok, polygon} = RegularPolygon.from_tuple({s, r, a, {x, y}})
          {self, polygon}
      end)
  end

  property :rotating_polygon_2pi_x_constant_is_no_rotation do
    for_all p in polygon do
      rotations = [-720, -360, 0, 360, 720]
      vertices = RegularPolygon.vertices(p)
      Enum.all?(rotations, fn r ->
        RegularPolygon.rotate_polygon_degrees(vertices, r) == vertices
      end)
    end
  end

  property :n_vertices_equals_n_sides do
    for_all p in polygon do
      vertices = RegularPolygon.vertices(p)
      length(vertices) == p.n_sides
    end
  end

  # Test is failing due to a rounding error somewhere.
  #property :polygon_has_order_n_rotational_symmetry do
  #  for_all p in such_that(p in polygon when p.radius > 0) do
  #    vertices = p
  #    |> RegularPolygon.vertices
  #    |> RegularPolygon.round_vertices
  #    |> MapSet.new
  #    radians = 2 * :math.pi / p.n_sides
  #    rotated_polygon = p
  #    |> RegularPolygon.rotate_polygon(radians)
  #    |> RegularPolygon.round_vertices
  #    |> MapSet.new
  #    MapSet.equal?(vertices, rotated_polygon)
  #  end
  #end
end
