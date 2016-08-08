defmodule Collision.Polygon.RegularPolygonTest do
  use ExUnit.Case
  use ExCheck
  doctest Collision.Polygon.RegularPolygon
  alias Collision.Polygon.RegularPolygon
  alias Collision.Polygon.Vertex

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
          s = max(polygon.sides - 2, 3)
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
      Enum.all?(rotations, fn r ->
        rotated = RegularPolygon.rotate_polygon_degrees(p, r)
        Vertex.round_vertices(p.polygon.vertices) ==
          Vertex.round_vertices(rotated.polygon.vertices)
      end)
    end
  end

  property :n_vertices_equals_sides do
    for_all p in polygon do
      length(p.polygon.vertices) == p.sides &&
        p.sides == length(p.polygon.edges)
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

  property :translation_moves_a_polygon do
    for_all {p, x, y} in {polygon, int, int} do
      polygon_translated = p
      |> RegularPolygon.translate_polygon(%{x: x, y: y})

      zipped_vertices = Enum.zip(p.polygon.vertices, polygon_translated.polygon.vertices)
      Enum.all?(
        for {p, t} <- zipped_vertices do
          round(t.x) == round(p.x + x) && round(t.y) == round(p.y + y)
        end
      )
    end
  end
end
