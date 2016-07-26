defmodule CollisionVector2Test do
  use ExUnit.Case
  use ExCheck
  doctest Collision.Vector2
  alias Collision.Vector2

  property :add_vectors do
    for_all {x1, y1, x2, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector2.add(v1, v2) == Vector2.from_tuple({x1+x2, y1+y2})
    end
  end

  property :subtract_vectors do
    for_all {x1, y1, x2, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector2.subtract(v1, v2) == Vector2.from_tuple({x1-x2, y1-y2})
    end
  end

  property :magnitude_of_a_vector do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      sum_of_squares = :math.pow(x1, 2) + :math.pow(y1, 2)
      Vector2.magnitude(v1) == :math.sqrt(sum_of_squares)
    end
  end

  property :normalize_a_vector do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v1_magnitude = Vector2.magnitude(v1)
      Vector2.normalize(v1) == %Vector2{x: x1/v1_magnitude, y: y1/v1_magnitude}
    end
  end

  property :calculate_dot_product do
    for_all {x1, x2, y1, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector2.dot_product(v1, v2) == (x1 * x2) + (y1 * y2)
    end
  end

  property :vector_projection do
    for_all {x1, x2, y1, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      dot_product = Vector2.dot_product(v1, v2)
      x = (dot_product / Vector2.magnitude(v2)) * x2
      y = (dot_product / Vector2.magnitude(v2)) * y2
      Vector2.projection(v1, v2) == %Vector2{x: x, y: y}
    end
  end

  property :vector_right_normal do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      Vector2.right_normal(v1) == %Vector2{x: -y1, y: x1}
    end
  end

  property :vector_left_normal do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      Vector2.left_normal(v1) == %Vector2{x: y1, y: -x1}
    end
  end

  property :per_product do
    for_all {x1, x2, y1, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector2.per_product(v1, v2) ==
        Vector2.dot_product(v1, Vector2.right_normal(v2))
    end
  end
end
