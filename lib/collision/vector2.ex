defmodule Collision.Vector2 do
  @moduledoc """
  Two-dimensional vectors used in detecting collisions.

  """
  defstruct x: 0.0, y: 0.0
  alias Collision.Vector2
  @type t :: Vector2.t

  @doc """
  Convert a tuple to a vector.

  ## Examples

  iex> Collision.Vector2.from_tuple({1.0, 1.5})
  %Collision.Vector2{x: 1.0, y: 1.5}
  """
  @spec from_tuple({float, float}) :: t
  def from_tuple({x, y}), do: %Vector2{x: x, y: y}

  @doc """
  Right normal of a vector.

  ## Examples

  iex> Collision.Vector2.right_normal(%Collision.Vector2{x: 3.0, y: 4.0})
  %Collision.Vector2{x: -4.0, y: 3.0}
  """
  @spec right_normal(t) :: t
  def right_normal(%Vector2{x: x1, y: y1}) do
    %Vector2{x: -y1, y: x1}
  end

  @doc """
  Left normal of a vector.
  This is the equivalent of a cross product of a single 2D vector.

  ## Examples

  iex> Collision.Vector2.left_normal(%Collision.Vector2{x: 3.0, y: 4.0})
  %Collision.Vector2{x: 4.0, y: -3.0}
  """
  @spec left_normal(t) :: t
  def left_normal(%Vector2{x: x1, y: y1}) do
    %Vector2{x: y1, y: -x1}
  end

  @doc """
  Per product of a pair of 2D vectors.

  ## Examples

  iex> Collision.Vector2.per_product(%Collision.Vector2{x: 3.0, y: 4.0}, %Collision.Vector2{x: -1.0, y: 2.0})
  -10.0
  """
  @spec per_product(t, t) :: float
  def per_product(%Vector2{} = v1, %Vector2{} = v2) do
    Vector.dot_product(v1, right_normal(v2))
  end

  defimpl Vector, for: Vector2 do
    @type t :: %{x: float, y: float}

    @spec to_tuple(t) :: {float, float}
    def to_tuple(%Vector2{x: x1, y: y1}), do: {x1, y1}

    @spec add(t, t) :: t
    def add(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
      %Vector2{x: x1 + x2, y: y1 + y2}
    end

    @spec subtract(t, t) :: t
    def subtract(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
      %Vector2{x: x1 - x2, y: y1 - y2}
    end

    @spec magnitude(t) :: float
    def magnitude(%Vector2{x: x1, y: y1}) do
      :math.sqrt(:math.pow(x1, 2) + :math.pow(y1, 2))
    end

    @spec normalize(t) :: t
    def normalize(%Vector2{x: x1, y: y1} = v1) do
      magnitude = magnitude(v1)
      %Vector2{x: x1/magnitude, y: y1/magnitude}
    end

    @spec dot_product(t, t) :: float
    def dot_product(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
      x1 * x2 + y1 * y2
    end

    @spec projection(t, t) :: t
    def projection(%Vector2{} = v1, %Vector2{x: x2, y: y2} = v2) do
      dot_product = dot_product(v1, v2)
      x = (dot_product / magnitude(v2)) * x2
      y = (dot_product / magnitude(v2)) * y2
      %Vector2{x: x, y: y}
    end

    @spec cross_product(t, t) :: t
    def cross_product(%Vector2{} = v1, _v2) do
      Vector2.right_normal(v1)
    end
  end
end
