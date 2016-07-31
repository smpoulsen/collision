defmodule Collision.SeparatingAxisTest do
  use ExUnit.Case
  use ExCheck
  alias Collision.SeparatingAxis
  alias Collision.Polygon.RegularPolygon
  alias Collision.Polygon.RegularPolygonTest
  doctest Collision.SeparatingAxis

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

  property :polygons_in_collision_have_an_mtv do
    for_all {p1, p2} in such_that(
      {pp1, pp2} in {RegularPolygonTest.polygon, RegularPolygonTest.polygon}
      when SeparatingAxis.collision?(pp1, pp2)
    ) do
      !is_nil(SeparatingAxis.collision_mtv(p1, p2))
    end
  end

  @tag iterations: 1000
  property :no_collision_gives_no_mtv do
    for_all {p1, p2} in {RegularPolygonTest.polygon, RegularPolygonTest.polygon} do
      implies (SeparatingAxis.collision?(p1, p2) == false) do
        is_nil(SeparatingAxis.collision_mtv(p1, p2))
      end
    end
  end

  @tag iterations: 1000
  property :translating_by_mtv_resolves_collision do
    for_all {p1, p2} in such_that(
      {pp1, pp2} in {RegularPolygonTest.polygon, RegularPolygonTest.polygon}
      when SeparatingAxis.collision?(pp1, pp2)
    ) do
      SeparatingAxis.collision?(p1, p2)
      {mtv, magnitude} = SeparatingAxis.collision_mtv(p1, p2)
      p1_translated = RegularPolygon.translate_polygon(p1, Vector.scalar_mult(mtv, magnitude))
      p2_translated = RegularPolygon.translate_polygon(p2, Vector.scalar_mult(mtv, magnitude))
      p1_vertices = RegularPolygon.calculate_vertices(p1)
      p2_vertices = RegularPolygon.calculate_vertices(p2)
      require IEx
      IEx.pry
      !SeparatingAxis.collision?(p1_translated, p2_vertices)
    end
  end
end
