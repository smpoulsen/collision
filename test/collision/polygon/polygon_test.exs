defmodule Collision.PolygonTest do
  use ExUnit.Case
  use ExCheck
  alias Collision.Polygon
  alias Collision.Polygon.Edge
  alias Collision.Polygon.Vertex
  doctest Collision.Polygon

  # Generator for vertex
  def vertex do
    domain(:vertex,
      fn(self, size) ->
        {_, x1} = :triq_dom.pick(int, size)
        {_, y1} = :triq_dom.pick(int, size)
        vertex = %Vertex{x: x1, y: y1}
        {self, vertex}
      end, fn
        (self, edge) ->
          x1 = max(edge.point.x - 2, 0)
          y1 = max(edge.point.y - 2, 0)
          vertex = %Vertex{x: x1, y: y1}
          {self, vertex}
      end)
  end
  # Generator for Polygons
  def polygon do
    domain(:polygon,
      fn(self, _size) ->
        {_, n_vertices} = :triq_dom.pick(:triq_dom.elements([6,7,8,9,10,11,12]), 10)
        vertices = 3..n_vertices
        |> Stream.map(fn _x -> :triq_dom.pick(vertex, 50) end)
        |> Enum.map(fn {_, v} -> v end)
        |> Vertex.graham_scan

        polygon = Polygon.from_vertices(vertices)
        {self, polygon}
      end, fn
        (self, polygon) ->
          {self, polygon}
          vertices = for vertex <- polygon.vertices do
            %Vertex{x: max(vertex.x - 2, 0), y: max(vertex.y - 2, 0)}
          end
          polygon = Polygon.from_vertices(vertices)
          {self, polygon}
      end)
  end
  # Generator for regular polygons
  def regular_polygon do
    domain(:regular_polygon,
      fn(self, size) ->
        {_, s} = :triq_dom.pick(elements([3,4,5,6,7,8,9,10,11,12]), size)
        {_, r} = :triq_dom.pick(choose(1, 50), size)
        {_, a} = :triq_dom.pick(non_neg_integer, size)
        {_, x} = :triq_dom.pick(non_neg_integer, size)
        {_, y} = :triq_dom.pick(non_neg_integer, size)
        regular_polygon = Polygon.gen_regular_polygon(s, max(r, 1), a, {x, y})
        {self, regular_polygon}
      end, fn
        (self, regular_polygon) ->
          {self, regular_polygon}
          vertices = for vertex <- regular_polygon.vertices do
            %Vertex{x: max(vertex.x - 2, 0), y: max(vertex.y - 2, 0)}
          end
          regular_polygon = Polygon.from_vertices(vertices)
          {self, regular_polygon}
      end)
  end

  property :rotating_polygon_2pi_x_constant_is_no_rotation do
    for_all p in polygon do
      rotations = [-720, -360, 0, 360, 720]
      Enum.all?(rotations, fn r ->
        rotated = Polygon.rotate_polygon_degrees(p, r)
        Vertex.round_vertices(p.vertices) == Vertex.round_vertices(rotated.vertices)
      end)
    end
  end

  property :n_vertices_equals_n_edges do
    for_all p in polygon do
      length(p.vertices) == p.edges |> length
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
      |> Polygon.translate_polygon(%{x: x, y: y})

      zipped_vertices = Enum.zip(p.vertices, polygon_translated.vertices)
      Enum.all?(
        for {p, t} <- zipped_vertices do
          t.x == (p.x + x) && t.y == (p.y + y)
        end
      )
    end
  end

  # Tests for regular polygons
  property :rotating_regular_polygon_2pi_x_constant_is_no_rotation do
    for_all p in regular_polygon do
      rotations = [-720, -360, 0, 360, 720]
      Enum.all?(rotations, fn r ->
        rotated = Polygon.rotate_polygon_degrees(p, r)
        Vertex.round_vertices(p.vertices) ==
          Vertex.round_vertices(rotated.vertices)
      end)
    end
  end

  property :translating_regular_polygon_by_mtv_resolves_collision do
    for_all {p1, p2} in such_that({pp1, pp2} in {regular_polygon, regular_polygon}
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

  property :translation_moves_a_regular_polygon do
    for_all {p, x, y} in {regular_polygon, int, int} do
      polygon_translated = p
      |> Polygon.translate_polygon(%{x: x, y: y})

      zipped_vertices = Enum.zip(p.vertices, polygon_translated.vertices)
      Enum.all?(
        for {p, t} <- zipped_vertices do
          round(t.x) == round(p.x + x) && round(t.y) == round(p.y + y)
        end
      )
    end
  end

end
