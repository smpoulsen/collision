defmodule Collision.Vector2 do
  @moduledoc """
  Basic vectors used in detecting collisions.
  """
  defstruct x: 0.0, y: 0.0
  alias Collision.Vector2
  @type t :: %{x: float, y: float}

  @doc """
  Convert a tuple to a vector.

  ## Examples

  iex> Collision.Vector2.from_tuple({1.0, 1.5})
  %Collision.Vector2{x: 1.0, y: 1.5}
  """
  @spec from_tuple({float, float}) :: t
  def from_tuple({x, y}), do: %Vector2{x: x, y: y}

  @doc """
  Add two vectors together.

  ## Examples

  iex> Collision.Vector2.add(%Collision.Vector2{x: 1.0, y: 1.0}, %Collision.Vector2{x: 2.0, y: 2.0})
  %Collision.Vector2{x: 3.0, y: 3.0}
  """
  @spec add(t, t) :: t
  def add(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
    %Vector2{x: x1 + x2, y: y1 + y2}
  end

  @doc """
  Subtract two vectors.

  ## Examples

  iex> Collision.Vector2.subtract(%Collision.Vector2{x: 4.0, y: 1.0}, %Collision.Vector2{x: 1.0, y: 4.0})
  %Collision.Vector2{x: 3.0, y: -3.0}
  """
  @spec subtract(t, t) :: t
  def subtract(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
    %Vector2{x: x1 - x2, y: y1 - y2}
  end

  @doc """
  Calculate the magnitude of a vector.

  ## Examples

  iex> Collision.Vector2.magnitude(%Collision.Vector2{x: 3.0, y: 4.0})
  5.0
  """
  @spec magnitude(t) :: float
  def magnitude(%Vector2{x: x1, y: y1}) do
    :math.sqrt(:math.pow(x1, 2) + :math.pow(y1, 2))
  end

  @doc """
  Normalize a vector.

  ## Examples

  iex> Collision.Vector2.normalize(%Collision.Vector2{x: 3.0, y: 4.0})
  %Collision.Vector2{x: 0.6, y: 0.8}
  """
  @spec normalize(t) :: t
  def normalize(%Vector2{x: x1, y: y1} = v1) do
    magnitude = magnitude(v1)
    %Vector2{x: x1/magnitude, y: y1/magnitude}
  end

  @doc """
  Calculate the dot product of two vectors.

  A negative value indicates they are moving away from each other,
  positive towards.

  ## Examples

  iex> Collision.Vector2.dot_product(%Collision.Vector2{x: 3.0, y: 4.0}, %Collision.Vector2{x: -1.0, y: 2.0})
  5.0
  """
  @spec dot_product(t, t) :: float
  def dot_product(%Vector2{x: x1, y: y1}, %Vector2{x: x2, y: y2}) do
    x1 * x2 + y1 * y2
  end

  @doc """
  Project a vector, v1, onto another, v2.

  ## Examples

  iex> Collision.Vector2.projection(%Collision.Vector2{x: 3.0, y: 4.0}, %Collision.Vector2{x: -1.0, y: 2.0})
  %Collision.Vector2{x: -2.23606797749979, y: 4.47213595499958}
  """
  @spec projection(t, t) :: t
  def projection(%Vector2{} = v1, %Vector2{x: x2, y: y2} = v2) do
    dot_product = dot_product(v1, v2)
    x = (dot_product / magnitude(v2)) * x2
    y = (dot_product / magnitude(v2)) * y2
    %Vector2{x: x, y: y}
  end

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

  ## Examples

  iex> Collision.Vector2.left_normal(%Collision.Vector2{x: 3.0, y: 4.0})
  %Collision.Vector2{x: 4.0, y: -3.0}
  """
  @spec right_normal(t) :: t
  def left_normal(%Vector2{x: x1, y: y1}) do
    %Vector2{x: y1, y: -x1}
  end

  @doc """
  Per product of a pair of vectors.

  ## Examples

  iex> Collision.Vector2.per_product(%Collision.Vector2{x: 3.0, y: 4.0}, %Collision.Vector2{x: -1.0, y: 2.0})
  -10.0
  """
  @spec per_product(t, t) :: float
  def per_product(%Vector2{} = v1, %Vector2{} = v2) do
    dot_product(v1, right_normal(v2))
  end
end
