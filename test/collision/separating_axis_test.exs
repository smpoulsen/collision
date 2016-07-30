defmodule Collision.SeparatingAxisTest do
  use ExUnit.Case
  use ExCheck
  doctest Collision.SeparatingAxis
  alias Collision.SeparatingAxis
  alias Collision.Polygon.RegularPolygon

  # Generator for RegularPolygon values
  def polygon_at_origin do
    domain(:polygon_at_origin,
      fn(self, size) ->
        {_, s} = :triq_dom.pick(non_neg_integer, size)
        {_, r} = :triq_dom.pick(non_neg_integer, size)
        {_, a} = :triq_dom.pick(non_neg_integer, size)
        {:ok, polygon} = RegularPolygon.from_tuple({max(s, 3), max(r, 1), a, {0, 0}})
        {self, polygon}
      end,
      fn (self, polygon) ->
        s = max(polygon.n_sides - 2, 3)
        r = max(polygon.radius - 2, 1)
        a = max(polygon.rotation_angle - 2, 0)
        {:ok, polygon} = RegularPolygon.from_tuple({s, r, a, {0, 0}})
        {self, polygon}
      end)
  end

  property :polygons_with_the_same_midpoint_are_in_collision do
    for_all {p1, p2} in {polygon_at_origin, polygon_at_origin} do
      SeparatingAxis.collision?(p1, p2)
    end
  end

  property :polygons_with_the_same_midpoint_have_an_mtv do
    for_all {p1, p2} in {polygon_at_origin, polygon_at_origin} do
      !is_nil(SeparatingAxis.collision_mtv(p1, p2))
    end
  end
end
