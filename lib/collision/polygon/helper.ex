defmodule Collision.Polygon.Helper do
  @moduledoc """
  Helper functions useful for all polygons.
  """

  @type degrees :: number
  @type radians :: float

  @doc """
  Convert degrees to radians. All rotation functions expect
  angles in radians.

  ## Examples
    iex> Collision.Polygon.Helper.degrees_to_radians(180)
    :math.pi
  """
  @spec degrees_to_radians(degrees) :: radians
  def degrees_to_radians(degrees) do
    degrees * (:math.pi / 180)
  end
end
