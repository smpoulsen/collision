defmodule CollisionVector2Test do
  use ExUnit.Case
  use ExCheck
  doctest Collision.Vector2
  alias Collision.Vector2

  # Properties for addition
  property :add_vectors do
    for_all {x1, y1, x2, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector.add(v1, v2) == Vector2.from_tuple({x1+x2, y1+y2})
    end
  end

  property :addition_is_commutative do
    for_all {x1, y1, x2, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector.add(v1, v2) == Vector.add(v2, v1)
    end
  end

  property :addition_is_associative do
    for_all {x1, y1, x2, y2, x3, y3} in {real, real, real, real, real, real} do
      round_vector = fn {a, b} -> {Float.round(a, 10), Float.round(b, 10)} end
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      v3 = Vector2.from_tuple({x3, y3})
      sum_one = Vector.add(Vector.add(v1, v2), v3)
      sum_two = Vector.add(v1, Vector.add(v2, v3))
      round_vector.(Vector.to_tuple(sum_one)) == round_vector.(Vector.to_tuple(sum_two))
    end
  end

  property :additive_identity do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      Vector.add(v1, Vector2.from_tuple({0,0})) == v1
    end
  end

  property :additive_inverse do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({-x1, -y1})
      Vector.add(v1, v2) == Vector2.from_tuple({0,0})
    end
  end

  # Subtraction properties
  property :subtract_vectors do
    for_all {x1, y1, x2, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector.subtract(v1, v2) == Vector2.from_tuple({x1-x2, y1-y2})
    end
  end

  property :magnitude_of_a_vector do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      sum_of_squares = :math.pow(x1, 2) + :math.pow(y1, 2)
      Vector.magnitude(v1) == :math.sqrt(sum_of_squares)
    end
  end

  property :normalize_a_vector do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v1_magnitude = Vector.magnitude(v1)
      Vector.normalize(v1) == %Vector2{x: x1/v1_magnitude, y: y1/v1_magnitude}
    end
  end

  # Dot product properties
  property :calculate_dot_product do
    for_all {x1, x2, y1, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector.dot_product(v1, v2) == (x1 * x2) + (y1 * y2)
    end
  end

  property :dot_product_is_commutative do
    for_all {x1, x2, y1, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector.dot_product(v1, v2) == Vector.dot_product(v2, v1)
    end
  end

  property :dot_product_is_distibutive do
    for_all {x1, y1, x2, y2, x3, y3} in {real, real, real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      v3 = Vector2.from_tuple({x3, y3})
      product_one = Vector.dot_product(v1, Vector.add(v2, v3))
      product_two = Vector.dot_product(v1, v2) + Vector.dot_product(v1, v3)
      Float.round(product_one, 10) == Float.round(product_two, 10)
    end
  end

  property :vector_projection do
    for_all {x1, x2, y1, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      dot_product = Vector.dot_product(v1, v2)
      x = (dot_product / Vector.magnitude(v2)) * x2
      y = (dot_product / Vector.magnitude(v2)) * y2
      Vector.projection(v1, v2) == %Vector2{x: x, y: y}
    end
  end

  property :vector_right_normal do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      Vector.right_normal(v1) == %Vector2{x: -y1, y: x1}
    end
  end

  property :vector_left_normal do
    for_all {x1, y1} in {real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      Vector.left_normal(v1) == %Vector2{x: y1, y: -x1}
    end
  end

  property :per_product do
    for_all {x1, x2, y1, y2} in {real, real, real, real} do
      v1 = Vector2.from_tuple({x1, y1})
      v2 = Vector2.from_tuple({x2, y2})
      Vector.per_product(v1, v2) ==
        Vector.dot_product(v1, Vector.right_normal(v2))
    end
  end
end
