defmodule Collision do
  @moduledoc """
  Wrapper around functionality to generate polygons and test for collisions.
  """
  alias Collision.Polygon.RegularPolygon
  alias Collision.SeparatingAxis

  @doc """
  Create a two dimensional, regular polygon from a number of sides,
  radius, rotation angle, and a midpoint (x, y coordinates).

  Returns: %RegularPolygon{}

  ## Examples
  iex> Collision.two_dimensional_polygon(4, 2, 0, {0, 0})
  %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2,
  rotation_angle: 0.0, midpoint: %Collision.Polygon.Vertex{x: 0, y: 0}}
  """
  @spec two_dimensional_polygon(integer, integer, number, {number, number}) :: RegularPolygon.t
  def two_dimensional_polygon(sides, radius, rotation_angle, {x, y}) do
    {:ok, p} = RegularPolygon.from_tuple({sides, radius, rotation_angle, {x, y}})
     p
  end

  @doc """
  Test for collision between two two-dimensional polygons.

  Returns: boolean

  ## Examples
  iex> Collision.two_dimensional_collision?(
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2, midpoint: %{x: 4, y: 4}}
  ...> )
  false

  iex> Collision.two_dimensional_collision?(
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 4,
  ...>     midpoint: %{x: 4, y: 2}}
  ...> )
  true
  """
  @spec two_dimensional_collision?(RegularPolygon.t, RegularPolygon.t) :: boolean
  def two_dimensional_collision?(polygon1, polygon2) do
    SeparatingAxis.collision?(polygon1, polygon2)
  end

  @doc """
  Test for collision between two two-dimensional polygons and return
  the minimum translation vector and magnitude to resolve collision.

  Returns: nil | {%Vector2{}, float}

  ## Examples
  iex> Collision.SeparatingAxis.collision_mtv(
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2, midpoint: %{x: 4, y: 4}}
  ...> )
  nil

  iex> Collision.SeparatingAxis.collision_mtv(
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 4,
  ...>     midpoint: %{x: 4, y: 1}}
  ...> )
  {%Collision.Vector.Vector2{x: 2.0, y: 2.0}, 2.0}
  """
  @spec two_dimensional_mtv(RegularPolygon.t, RegularPolygon.t) :: boolean
  def two_dimensional_mtv(polygon1, polygon2) do
    SeparatingAxis.collision_mtv(polygon1, polygon2)
  end
end
