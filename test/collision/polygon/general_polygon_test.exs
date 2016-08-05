defmodule GeneralPolygonTest do
  use ExUnit.Case
  use ExCheck
  doctest Collision.Polygon

  alias Collision.Polygon
  alias Collision.Polygon.Vertex

  # Generator for vertex
  def vertex do
    domain(:vertex,
      fn(self, size) ->
        {_, x1} = :triq_dom.pick(non_neg_integer, size)
        {_, y1} = :triq_dom.pick(non_neg_integer, size)
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
  # Generator for Polygon values
  def polygon do
    domain(:polygon,
      fn(self, size) ->
        {_, n_vertices} = :triq_dom.pick(:triq_dom.elements([3,4,5,6,7,8,9,10]), size)
        vertices = 0..n_vertices
        |> Stream.map(fn _x -> :triq_dom.pick(vertex, size) end)
        |> Enum.map(fn {_, v} -> v end)
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

  property :rotating_polygon_2pi_x_constant_is_no_rotation do
    for_all p in polygon do
      rotations = [-720, -360, 0, 360, 720]
      vertices = p
      Enum.all?(rotations, fn r ->
        Polygon.rotate_polygon_degrees(vertices, r) == vertices
      end)
    end
  end

  property :n_vertices_equals_n_sides do
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

  property :translation_is_same_for_polygon_and_vertices do
    for_all {p, x, y} in {polygon, int, int} do
      polygon_translated = p
      |> Polygon.translate_polygon(%{x: x, y: y})
      |> Polygon.calculate_vertices
      |> Polygon.round_vertices
      vertices_translated = p
      |> Polygon.calculate_vertices
      |> Polygon.translate_vertices(%{x: x, y: y})
      |> Polygon.round_vertices
      polygon_translated == vertices_translated
    end
  end
end
