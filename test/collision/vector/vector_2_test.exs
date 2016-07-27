defmodule Collision.Vector.Vector2Test do
  use ExUnit.Case
  use ExCheck
  doctest Collision.Vector.Vector2
  alias Collision.Vector.Vector2

  # Generator for Vector2 values
  def vector2 do
    domain(:vector2,
      fn(self, size) ->
        {_, x} = :triq_dom.pick(real, size)
        {_, y} = :triq_dom.pick(real, size)
        vector = Vector2.from_tuple({x, y})
        {self, vector}
      end, fn
        (self, vector) ->
        x = max(vector.x - 2, 0)
        y = max(vector.y - 2, 0)
        vector = Vector2.from_tuple({x, y})
        {self, vector}
      end)
  end

  property :scalar_multiplication do
    for_all {v1, k} in {vector2, real} do
      Vector.scalar_mult(v1, k) ==
        %Vector2{x: v1.x * k, y: v1.y * k}
    end
  end

  property :scalar_multiplication_identity do
    for_all {v1} in {vector2} do
      Vector.scalar_mult(v1, 1) == v1
    end
  end

  property :scalar_multiplication_commutative do
    for_all {v1, v2, k} in {vector2, vector2, real} do
      Vector.round_components(Vector.scalar_mult(Vector.add(v1, v2), k), 5) ==
        Vector.round_components(Vector.add(Vector.scalar_mult(v1, k), Vector.scalar_mult(v2, k)), 5)
    end
  end

  # Properties for addition
  property :add_vectors do
    for_all {v1, v2} in {vector2, vector2} do
      Vector.add(v1, v2) == Vector2.from_tuple({v1.x + v2.x, v1.y + v2.y})
    end
  end

  property :addition_is_commutative do
    for_all {v1, v2} in {vector2, vector2} do
      Vector.add(v1, v2) == Vector.add(v2, v1)
    end
  end

  property :addition_is_associative do
    for_all {v1, v2, v3} in {vector2, vector2, vector2} do
      round_vector = fn {a, b} -> {Float.round(a, 10), Float.round(b, 10)} end
      sum_one = Vector.add(Vector.add(v1, v2), v3)
      sum_two = Vector.add(v1, Vector.add(v2, v3))
      round_vector.(Vector.to_tuple(sum_one)) == round_vector.(Vector.to_tuple(sum_two))
    end
  end

  property :additive_identity do
    for_all {v1} in {vector2} do
      Vector.add(v1, Vector2.from_tuple({0,0})) == v1
    end
  end

  property :additive_inverse do
    for_all {v1} in {vector2} do
      v2 = Vector2.from_tuple({-v1.x, -v1.y})
      Vector.add(v1, v2) == Vector2.from_tuple({0,0})
    end
  end

  # Subtraction properties
  property :subtract_vectors do
    for_all {v1, v2} in {vector2, vector2} do
      Vector.subtract(v1, v2) == Vector2.from_tuple({v1.x - v2.x, v1.y - v2.y})
    end
  end

  property :subtractive_identity do
    for_all {v1} in {vector2} do
      Vector.subtract(v1, Vector2.from_tuple({0,0})) == v1
    end
  end

  property :magnitude_of_a_vector do
    for_all {v1} in {vector2} do
      sum_of_squares = :math.pow(v1.x, 2) + :math.pow(v1.y, 2)
      Vector.magnitude(v1) == :math.sqrt(sum_of_squares)
    end
  end

  property :normalize_a_vector do
    for_all {v1} in {vector2} do
      v1_magnitude = Vector.magnitude(v1)
      Vector.normalize(v1) == %Vector2{x: v1.x/v1_magnitude, y: v1.y/v1_magnitude}
    end
  end

  # Dot product properties
  property :calculate_dot_product do
    for_all {v1, v2} in {vector2, vector2} do
      Vector.dot_product(v1, v2) == (v1.x * v2.x) + (v1.y * v2.y)
    end
  end

  property :dot_product_is_commutative do
    for_all {v1, v2} in {vector2, vector2} do
      Vector.dot_product(v1, v2) == Vector.dot_product(v2, v1)
    end
  end

  property :dot_product_is_distibutive do
    for_all {v1, v2, v3} in {vector2, vector2, vector2} do
      product_one = Vector.dot_product(v1, Vector.add(v2, v3))
      product_two = Vector.dot_product(v1, v2) + Vector.dot_product(v1, v3)
      Float.round(product_one, 5) == Float.round(product_two, 5)
    end
  end

  property :vector_projection do
    for_all {v1, v2} in {vector2, vector2} do
      dot_product = Vector.dot_product(v1, v2)
      x = (dot_product / Vector.magnitude_squared(v2)) * v2.x
      y = (dot_product / Vector.magnitude_squared(v2)) * v2.y
      Vector.projection(v1, v2) == %Vector2{x: x, y: y}
    end
  end

  property :vector_right_normal do
    for_all {v1} in {vector2} do
      Vector2.right_normal(v1) == %Vector2{x: -v1.y, y: v1.x}
    end
  end

  property :vector_left_normal do
    for_all {v1} in {vector2} do
      Vector2.left_normal(v1) == %Vector2{x: v1.y, y: -v1.x}
    end
  end

  property :per_product do
    for_all {v1, v2} in {vector2, vector2} do
      Vector2.per_product(v1, v2) ==
        Vector.dot_product(v1, Vector2.right_normal(v2))
    end
  end
end
