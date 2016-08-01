defmodule Collision.Polygon.RegularPolygonTest do
  use ExUnit.Case
  use ExCheck
  doctest Collision.Polygon.RegularPolygon
  alias Collision.Polygon.RegularPolygon

  # Generator for RegularPolygon values
  def polygon do
    domain(:polygon,
      fn(self, size) ->
        {_, s} = :triq_dom.pick(elements([3,4,5,6,7,8,9,10,11,12]), size)
        {_, r} = :triq_dom.pick(choose(1, 50), size)
        {_, a} = :triq_dom.pick(non_neg_integer, size)
        {_, x} = :triq_dom.pick(non_neg_integer, size)
        {_, y} = :triq_dom.pick(non_neg_integer, size)
        {:ok, polygon} = RegularPolygon.from_tuple({s, max(r, 1), a, {x, y}})
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
      vertices = RegularPolygon.calculate_vertices(p)
      Enum.all?(rotations, fn r ->
        RegularPolygon.rotate_polygon_degrees(vertices, r) == vertices
      end)
    end
  end

  property :n_vertices_equals_n_sides do
    for_all p in polygon do
      vertices = RegularPolygon.calculate_vertices(p)
      length(vertices) == p.n_sides
    end
  end

  property :translating_by_mtv_resolves_collision do
    for_all {p1, p2} in such_that({pp1, pp2} in {polygon, polygon}
      when Collidable.collision?(pp1, pp2)) do
      {_p1, p2_translated} = Collidable.resolve_collision(p1, p2)
      mtv = Collidable.resolution(p1, p2_translated)
      case mtv do
        nil -> true
        {_vector, magnitude} ->
          round(magnitude) == 0
      end
    end
  end

  property :translation_is_same_for_polygon_and_vertices do
    for_all {p, x, y} in {polygon, int, int} do
      polygon_translated = p
      |> RegularPolygon.translate_polygon(%{x: x, y: y})
      |> RegularPolygon.calculate_vertices
      |> RegularPolygon.round_vertices
      vertices_translated = p
      |> RegularPolygon.calculate_vertices
      |> RegularPolygon.translate_vertices(%{x: x, y: y})
      |> RegularPolygon.round_vertices
      polygon_translated == vertices_translated
    end
  end

end
