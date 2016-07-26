defmodule Collision.Vector3 do
  @moduledoc """
  Two-dimensional vectors used in detecting collisions.

  """
  defstruct x: 0.0, y: 0.0, z: 0.0
  alias Collision.Vector3
  @type t :: Vector3.t

  @doc """
  Convert a tuple to a vector.

  ## Examples

  iex> Collision.Vector3.from_tuple({1.0, 1.5, 2.0})
  %Collision.Vector3{x: 1.0, y: 1.5, z: 2.0}
  """
  @spec from_tuple({float, float}) :: t
  def from_tuple({x, y, z}), do: %Vector3{x: x, y: y, z: z}

  defimpl Vector, for: Vector3 do
    @type t :: Vector3.t

    @spec to_tuple(Vector3.t) :: {float, float, float}
    def to_tuple(%Vector3{x: x, y: y, z: z}), do: {x, y, z}

    @spec add(Vector3.t, Vector3.t) :: Vector3.t
    def add(%Vector3{x: x1, y: y1, z: z1}, %Vector3{x: x2, y: y2, z: z2}) do
      %Vector3{x: x1 + x2, y: y1 + y2, z: z1 + z2}
    end

    @spec subtract(Vector3.t, Vector3.t) :: Vector3.t
    def subtract(%Vector3{x: x1, y: y1, z: z1}, %Vector3{x: x2, y: y2, z: z2}) do
      %Vector3{x: x1 - x2, y: y1 - y2, z: z1 - z2}
    end

    @spec magnitude(t) :: float
    def magnitude(%Vector3{x: x1, y: y1, z: z1}) do
      :math.sqrt(:math.pow(x1, 2) + :math.pow(y1, 2) + :math.pow(z1, 2))
    end

    @spec normalize(t) :: t
    def normalize(%Vector3{x: x1, y: y1, z: z1} = v1) do
      magnitude = magnitude(v1)
      %Vector3{x: x1/magnitude, y: y1/magnitude, z: z1/magnitude}
    end

    @spec dot_product(t, t) :: float
    def dot_product(%Vector3{x: x1, y: y1, z: z1}, %Vector3{x: x2, y: y2, z: z2}) do
      x1 * x2 + y1 * y2 + z1 * z2
    end

    @spec projection(t, t) :: t
    def projection(%Vector3{} = v1, %Vector3{x: x2, y: y2, z: z2} = v2) do
      dot_product = dot_product(v1, v2)
      dot_product_normalized = dot_product / magnitude(v2)
      x = dot_product_normalized * x2
      y = dot_product_normalized * y2
      z = dot_product_normalized * z2
      %Vector3{x: x, y: y, z: z}
    end

    @spec cross_product(t, t) :: t
    def cross_product(%Vector3{x: x1, y: y1, z: z1}, %Vector3{x: x2, y: y2, z: z2}) do
      x_term = -z1 * y2 + y1 * z2
      y_term = z1 * x2 - x1 * z2
      z_term = -y1 * x2 + x1 * y2
      %Vector3{x: x_term, y: y_term, z: z_term}
    end
  end
end
