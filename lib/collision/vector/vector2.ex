defmodule Collision.Vector.Vector2 do
  @moduledoc """
  Two-dimensional vectors used in detecting collisions.

  """
  defstruct x: 0.0, y: 0.0
  alias Collision.Vector.Vector2
  @type t :: Vector2.t

  @doc """
  Convert a tuple to a vector.

  ## Examples
    iex> Collision.Vector.Vector2.from_tuple({1.0, 1.5})
    %Collision.Vector.Vector2{x: 1.0, y: 1.5}
  """
  @spec from_tuple({float, float}) :: t
  def from_tuple({x, y}), do: %Vector2{x: x, y: y}

  @doc """
  Get a vector from a set of points.

  ## Examples
    iex> Collision.Vector.Vector2.from_points(%{x: 5, y: 3}, %{x: 10, y: 6})
    %Collision.Vector.Vector2{x: 5, y: 3}
  """
  def from_points(%{x: x1, y: y1}, %{x: x2, y: y2}) do
    %Vector2{x: x2 - x1, y: y2 - y1}
  end
  def from_points({x1, y1}, {x2, y2}) do
    %Vector2{x: x2 - x1, y: y2 - y1}
  end

  @doc """
  Right normal of a vector.

  ## Examples
    iex> Collision.Vector.Vector2.right_normal(
    ...>   %Collision.Vector.Vector2{x: 3.0, y: 4.0}
    ...> )
    %Collision.Vector.Vector2{x: -4.0, y: 3.0}
  """
  @spec right_normal(t) :: t
  def right_normal(%Vector2{x: x1, y: y1}) do
    %Vector2{x: -y1, y: x1}
  end

  @doc """
  Left normal of a vector.
  This is the equivalent of a cross product of a single 2D vector.

  ## Examples
    iex> Collision.Vector.Vector2.left_normal(
    ...>   %Collision.Vector.Vector2{x: 3.0, y: 4.0}
    ...> )
    %Collision.Vector.Vector2{x: 4.0, y: -3.0}
  """
  @spec left_normal(t) :: t
  def left_normal(%Vector2{x: x1, y: y1}) do
    %Vector2{x: y1, y: -x1}
  end

  @doc """
  Per product of a pair of 2D vectors.

  ## Examples
    iex> Collision.Vector.Vector2.per_product(
    ...>   %Collision.Vector.Vector2{x: 3.0, y: 4.0},
    ...>   %Collision.Vector.Vector2{x: -1.0, y: 2.0}
    ...> )
    -10.0
  """
  @spec per_product(t, t) :: float
  def per_product(%Vector2{} = v1, %Vector2{} = v2) do
    Vector.dot_product(v1, right_normal(v2))
  end

  defimpl Vector, for: Vector2 do
    @type t :: Vector2.t
    @type scalar :: float

    @spec to_tuple(t) :: {float, float}
    def to_tuple(%Vector2{x: x1, y: y1}), do: {x1, y1}

    @spec round_components(t, integer) :: t
    def round_components(%Vector2{x: x, y: y}, n) do
      %Vector2{x: Float.round(x, n), y: Float.round(y, n)}
    end

    @spec scalar_mult(t, scalar) :: t
    def scalar_mult(%Vector2{x: x, y: y}, k) do
      %Vector2{x: x * k, y: y * k}
    end

    @spec add(t, t) :: t
    def add(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
      %Vector2{x: x1 + x2, y: y1 + y2}
    end

    @spec subtract(t, t) :: t
    def subtract(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
      %Vector2{x: x1 - x2, y: y1 - y2}
    end

    @spec magnitude(t) :: float
    def magnitude(%Vector2{} = v1) do
      :math.sqrt(magnitude_squared(v1))
    end

    @spec magnitude_squared(t) :: float
    def magnitude_squared(%Vector2{} = v1) do
      dot_product(v1, v1)
    end

    @spec normalize(t) :: t
    def normalize(%Vector2{x: x1, y: y1} = v1) do
      mag = magnitude(v1)
      %Vector2{x: x1 / mag, y: y1 / mag}
    end

    @spec dot_product(t, t) :: float
    def dot_product(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
      x1 * x2 + y1 * y2
    end

    @spec projection(t, t) :: t
    def projection(%Vector2{} = v1, %Vector2{} = v2) do
      scaled_dot = dot_product(v1, v2) / magnitude_squared(v2)
      Vector.scalar_mult(v2, scaled_dot)
    end

    @spec cross_product(t, t) :: t
    def cross_product(%Vector2{} = v1, _v2) do
      Vector2.right_normal(v1)
    end
  end
end
