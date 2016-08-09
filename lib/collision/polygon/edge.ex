defmodule Collision.Polygon.Edge do
  @moduledoc """
  An edge; the connection between two vertices.

  Represented as a point, the next point that its connected to, and the
  length between them.
  """
  defstruct point: nil, next: nil, length: nil

  alias Collision.Polygon.Edge
  alias Collision.Polygon.Vertex
  alias Collision.Vector.Vector2

  @type t :: t

  @doc """
  Build an edge from a pair of vertices.

  Returns: Edge.t | {:error, String.t}

  ## Example

      iex> Edge.from_vertex_pair({%Vertex{x: 0, y: 0}, %Vertex{x: 0, y: 4}})
      %Edge{point: %Vertex{x: 0, y: 0}, next: %Vertex{x: 0, y: 4}, length: 4.0}

  """
  @spec from_vertex_pair({Vertex.t, Vertex.t}) :: t | {:error, String.t}
  def from_vertex_pair({point1, point1}), do: {:error, "Same point"}
  def from_vertex_pair({point1, point2} = points) do
    edge_length = calculate_length(points)
    %Edge{point: point1, next: point2, length: edge_length}
  end

  @spec calculate_length({%{x: number, y: number}, %{x: number, y: number}}) :: float
  defp calculate_length({%{x: x1, y: y1}, %{x: x2, y: y2}}) do
    sum_of_squares = :math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2)
    :math.sqrt(sum_of_squares)
  end

  @doc """
  Calculate the angle between three vertices, A -> B -> C,
  based on the edges AB and BC.

  Returns: angle B, in radians

  ## Example

      iex> a = Edge.from_vertex_pair({%Vertex{x: 0, y: 0}, %Vertex{x: 0, y: 4}})
      iex> b = Edge.from_vertex_pair({%Vertex{x: 0, y: 4}, %Vertex{x: 4, y: 4}})
      iex> Edge.calculate_angle(a, b)
      :math.pi / 2

  """
  @spec calculate_angle(Edge.t, Edge.t) :: float | {:error, String.t}
  def calculate_angle([edge1, edge2]) do
    calculate_angle(edge1, edge2)
  end
  def calculate_angle(
        %Edge{point: %{x: _x1, y: _y1},
              next: %{x: x2, y: y2},
              length: length_1_2} = edge1,
        %Edge{point: %{x: x2, y: y2},
              next: %{x: _x3, y: _y3},
              length: length_2_3} = edge2
      ) do
    vector_1_2 = Vector2.from_points(edge1.point, edge2.point)
    vector_2_3 = Vector2.from_points(edge2.point, edge2.next)
    dot = Vector.dot_product(vector_1_2, vector_2_3)
    angle = dot / (length_1_2 + length_2_3)
    case abs(angle) do
      x when x > 1 ->
        {:error, "reflex angle"}
      _ ->
        :math.acos(angle)
    end
  end

  defimpl String.Chars, for: Edge do
    @spec to_string(Edge.t) :: String.t
    def to_string(%Edge{} = e) do
      "#{e.point} -> #{e.next}"
    end
  end
end
