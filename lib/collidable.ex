defprotocol Collidable do
  @moduledoc """

  """

  @doc """
  Determine whether a pair of collidable entities are in collision.

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
  Determine how to resolve the collision.

  Returns: {Vector, magnitude}

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

  @doc """
  Resolve the collision.

  Returns the the first entity and the translation of the second entity.

  Returns: {Collidable_entity, Collidable_entity}

  ## Examples

  iex> Collidable.resolve_collision(
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2, midpoint: %{x: 4, y: 4}}
  ...> )
  nil

  iex> Collidable.resolve_collision(
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 2},
  ...>   %Collision.Polygon.RegularPolygon{n_sides: 4, radius: 4,
  ...>     midpoint: %{x: 4, y: 1}}
  ...> )
  {%Collision.Vector.Vector2{x: 0.7071067811865475, y: 0.7071067811865475}, 0.7071067811865475}

  """
  def resolve_collision(any, any)
end
