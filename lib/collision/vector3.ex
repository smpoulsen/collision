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
    @type scalar :: float

    @spec to_tuple(Vector3.t) :: {float, float, float}
    def to_tuple(%Vector3{x: x, y: y, z: z}), do: {x, y, z}

    @spec round_components(Vector3.t, integer) :: Vector3.t
    def round_components(%Vector3{x: x, y: y, z: z}, n) do
      %Vector3{x: Float.round(x, n), y: Float.round(y, n), z: Float.round(z, n)}
    end

    @spec scalar_mult(Vector3.t, scalar) :: Vector3.t
    def scalar_mult(%Vector3{x: x, y: y, z: z}, k) do
      %Vector3{x: x * k, y: y * k, z: z * k}
    end

    @spec add(Vector3.t, Vector3.t) :: Vector3.t
    def add(%Vector3{x: x1, y: y1, z: z1}, %Vector3{x: x2, y: y2, z: z2}) do
      %Vector3{x: x1 + x2, y: y1 + y2, z: z1 + z2}
    end

    @spec subtract(Vector3.t, Vector3.t) :: Vector3.t
    def subtract(%Vector3{x: x1, y: y1, z: z1}, %Vector3{x: x2, y: y2, z: z2}) do
      %Vector3{x: x1 - x2, y: y1 - y2, z: z1 - z2}
    end

    @spec magnitude(t) :: float
    def magnitude(%Vector3{} = v1) do
      :math.sqrt(magnitude_squared(v1))
    end

    @spec magnitude_squared(t) :: float
    def magnitude_squared(%Vector3{} = v1) do
      dot_product(v1, v1)
    end

    @spec normalize(t) :: t
    def normalize(%Vector3{x: x1, y: y1, z: z1} = v1) do
      mag = magnitude(v1)
      %Vector3{x: x1 / mag, y: y1 / mag, z: z1 / mag}
    end

    @spec dot_product(t, t) :: float
    def dot_product(%Vector3{x: x1, y: y1, z: z1}, %Vector3{x: x2, y: y2, z: z2}) do
      x1 * x2 + y1 * y2 + z1 * z2
    end

    @spec projection(t, t) :: t
    def projection(%Vector3{} = v1, %Vector3{} = v2) do
      dot = dot_product(v1, v2)
      dot_normalized = dot / magnitude_squared(v2)
      Vector.scalar_mult(v2, dot_normalized)
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
