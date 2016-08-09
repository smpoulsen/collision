defmodule EdgeTest do
  use ExUnit.Case
  use ExCheck
  alias Collision.Polygon.Edge
  alias Collision.Polygon.Vertex
  doctest Collision.Polygon.Edge

  # Generator for edges
  def edge do
    domain(:edge,
      fn(self, size) ->
        {_, x1} = :triq_dom.pick(non_neg_integer, size)
        {_, y1} = :triq_dom.pick(non_neg_integer, size)
        {_, x2} = :triq_dom.pick(non_neg_integer, size)
        {_, y2} = :triq_dom.pick(non_neg_integer, size)
        v1 = %Vertex{x: x1, y: y1}
        v2 = %Vertex{x: x2, y: y2}
        edge = Edge.from_vertex_pair({v1, v2})
        {self, edge}
      end, fn
        (self, edge) ->
          x1 = max(edge.point.x - 2, 0)
          y1 = max(edge.point.y - 2, 0)
          x2 = max(edge.next.x - 2, 0)
          y2 = max(edge.next.y - 2, 0)
          v1 = %Vertex{x: x1, y: y1}
          v2 = %Vertex{x: x2, y: y2}
          edge = Edge.from_vertex_pair({v1, v2})
          {self, edge}
      end)
  end

  property :edges_have_non_zero_length do
    for_all e in such_that(eg in edge when eg !== {:error, "Same point"}) do
      e.length > 0
    end
  end
end
