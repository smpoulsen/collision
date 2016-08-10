defprotocol Collidable do
  @moduledoc """
  Protocol defining an interface for checking whether objects are colliding.

  In the event of collision, it also defines functions for resolution.
  """

  @doc """
  Determine whether a pair of collidable entities are in collision.

  ## Examples

      iex> Collidable.collision?(
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {0, 0}),
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {4, 4})
      ...> )
      false

      iex> Collidable.collision?(
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {0, 0}),
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {1, 1})
      ...> )
      true

  """
  def collision?(any, any)

  @doc """
  Determine how to resolve the collision.

  Returns: {Vector, magnitude}

  ## Examples

      iex> Collidable.resolution(
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {0, 0}),
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {4, 4})
      ...> )
      nil

      iex> Collidable.resolution(
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {0, 0}),
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {1, 1})
      ...> )
      {%Collision.Vector.Vector2{x: 0.7071067811865475, y: 0.7071067811865475}, 1.414213562373095}

  """
  def resolution(any, any)

  @doc """
  Resolve the collision.

  Returns the the first entity and the translation of the second entity.

  Returns: {Collidable_entity, Collidable_entity}

  ## Examples

      iex> Collidable.resolve_collision(
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {0, 0}),
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {4, 4})
      ...> )
      {%Polygon{convex: true, edges: [
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 0.0, y: 2.0}, point: %Vertex{x: 2.0, y: 0.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: -2.0, y: 0.0}, point: %Vertex{x: 0.0, y: 2.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 0.0, y: -2.0}, point: %Vertex{x: -2.0, y: 0.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 2.0, y: 0.0}, point: %Vertex{x: 0.0, y: -2.0}}
      ], vertices: [
        %Vertex{x: 2.0, y: 0.0}, %Vertex{x: 0.0, y: 2.0},
        %Vertex{x: -2.0, y: 0.0}, %Vertex{x: 0.0, y: -2.0}
      ]}, %Polygon{convex: true, edges: [
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 4.0, y: 6.0}, point: %Vertex{x: 6.0, y: 4.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 2.0, y: 4.0}, point: %Vertex{x: 4.0, y: 6.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 4.0, y: 2.0}, point: %Vertex{x: 2.0, y: 4.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 6.0, y: 4.0}, point: %Vertex{x: 4.0, y: 2.0}}],
        vertices: [%Vertex{x: 6.0, y: 4.0}, %Vertex{x: 4.0, y: 6.0},
        %Vertex{x: 2.0, y: 4.0}, %Vertex{x: 4.0, y: 2.0}
      ]}}

      iex> Collidable.resolve_collision(
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {0, 0}),
      ...>   Polygon.gen_regular_polygon(4, 2, 0, {1, 1})
      ...> )
      {%Polygon{edges: [
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 0.0, y: 2.0},
          point: %Vertex{x: 2.0, y: 0.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: -2.0, y: 0.0},
          point: %Vertex{x: 0.0, y: 2.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 0.0, y: -2.0},
          point: %Vertex{x: -2.0, y: 0.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 2.0, y: 0.0},
          point: %Vertex{x: 0.0, y: -2.0}}
      ], vertices: [
        %Vertex{x: 2.0, y: 0.0}, %Vertex{x: 0.0, y: 2.0},
        %Vertex{x: -2.0, y: 0.0}, %Vertex{x: 0.0, y: -2.0}]
      }, %Polygon{edges: [
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 2.0, y: 4.0},
          point: %Vertex{x: 4.0, y: 2.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 0.0, y: 2.0},
          point: %Vertex{x: 2.0, y: 4.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 2.0, y: 0.0},
          point: %Vertex{x: 0.0, y: 2.0}},
        %Edge{length: 2.8284271247461903, next: %Vertex{x: 4.0, y: 2.0},
          point: %Vertex{x: 2.0, y: -0.0}}
      ], vertices: [
        %Vertex{x: 4.0, y: 2.0}, %Vertex{x: 2.0, y: 4.0},
        %Vertex{x: 0.0, y: 2.0}, %Vertex{x: 2.0, y: 0.0}]}}
  """
  def resolve_collision(any, any)
end
