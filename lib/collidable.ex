defprotocol Collidable do
  @moduledoc """

  """

  @doc """
    ## Examples
    iex> Collidable.collision?(
      ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
      ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2, midpoint: %{x: 4, y: 4}}
      ...> )
    false

    iex> Collidable.SeparatingAxis.collision?(
      ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
      ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 4,
      ...>     midpoint: %{x: 4, y: 2}}
      ...> )
    true
  """
  def collision?(any, any)

  @doc """
  ## Examples
    iex> Collidable.resolution(
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2, midpoint: %{x: 4, y: 4}}
    ...> )
    nil

    iex> Collidable.resolution(
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
    ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 4,
    ...>     midpoint: %{x: 4, y: 1}}
    ...> )
    {%Collision.Vector.Vector2{x: 0.7071067811865475, y: 0.7071067811865475}, 0.7071067811865475}
  """
  def resolution(any, any)

  def resolve_collision(any, any)
end
