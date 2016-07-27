defmodule Collision.Vector.Vector3Test do
  use ExUnit.Case
  use ExCheck
  doctest Collision.Vector.Vector3
  alias Collision.Vector.Vector3

  # Generator for Vector3 values
  def vector3 do
    domain(:vector3,
      fn(self, size) ->
        {_, x} = :triq_dom.pick(real, size)
        {_, y} = :triq_dom.pick(real, size)
        {_, z} = :triq_dom.pick(real, size)
        vector = Vector3.from_tuple({x, y, z})
        {self, vector}
      end, fn
        (self, vector) ->
        x = max(vector.x - 2, 0)
        y = max(vector.y - 2, 0)
        z = max(vector.z - 2, 0)
        vector = Vector3.from_tuple({x, y, z})
        {self, vector}
      end)
  end

  property :scalar_multiplication do
    for_all {v1, k} in {vector3, real} do
      Vector.scalar_mult(v1, k) ==
        %Vector3{x: v1.x * k, y: v1.y * k, z: v1.z * k}
    end
  end

  property :scalar_multiplication_identity do
    for_all {v1} in {vector3} do
      Vector.scalar_mult(v1, 1) == v1
    end
  end

  property :scalar_multiplication_commutative do
    for_all {v1, v2, k} in {vector3, vector3, real} do
      Vector.round_components(Vector.scalar_mult(Vector.add(v1, v2), k), 5) ==
        Vector.round_components(Vector.add(Vector.scalar_mult(v1, k), Vector.scalar_mult(v2, k)), 5)
    end
  end

  # Properties for addition
  property :add_vectors do
    for_all {v1, v2} in {vector3, vector3} do
      Vector.add(v1, v2) ==
        Vector3.from_tuple({v1.x + v2.x, v1.y + v2.y, v1.z + v2.z})
    end
  end

  property :addition_is_commutative do
    for_all {v1, v2} in {vector3, vector3} do
      Vector.add(v1, v2) == Vector.add(v2, v1)
    end
  end

  property :addition_is_associative do
    for_all {v1, v2, v3} in {vector3, vector3, vector3} do
      round_vector = fn {a, b, c} ->
        {Float.round(a, 10), Float.round(b, 10), Float.round(c, 10)}
      end
      sum_one = Vector.add(Vector.add(v1, v2), v3)
      sum_two = Vector.add(v1, Vector.add(v2, v3))
      round_vector.(Vector.to_tuple(sum_one)) ==
        round_vector.(Vector.to_tuple(sum_two))
    end
  end

  property :additive_identity do
    for_all {v1} in {vector3} do
      Vector.add(v1, Vector3.from_tuple({0,0,0})) == v1
    end
  end

  property :additive_inverse do
    for_all {v1} in {vector3} do
      v2 = Vector3.from_tuple({-v1.x, -v1.y, -v1.z})
      Vector.add(v1, v2) == Vector3.from_tuple({0,0,0})
    end
  end

  # Subtraction properties
  property :subtract_vectors do
    for_all {v1, v2} in {vector3, vector3} do
      Vector.subtract(v1, v2) ==
        Vector3.from_tuple({v1.x - v2.x, v1.y - v2.y, v1.z - v2.z})
    end
  end

  property :subtractive_identity do
    for_all {v1} in {vector3} do
      Vector.subtract(v1, Vector3.from_tuple({0,0,0})) == v1
    end
  end

  property :magnitude_of_a_vector do
    for_all {v1} in {vector3} do
      sum_squares = :math.pow(v1.x, 2) + :math.pow(v1.y, 2) + :math.pow(v1.z, 2)
      Vector.magnitude(v1) == :math.sqrt(sum_squares)
    end
  end

  property :normalize_a_vector do
    for_all {v1} in {vector3} do
      v1_magnitude = Vector.magnitude(v1)
      Vector.normalize(v1) ==
        %Vector3{x: v1.x/v1_magnitude, y: v1.y/v1_magnitude, z: v1.z/v1_magnitude}
    end
  end

  # Dot product properties
  property :calculate_dot_product do
    for_all {v1, v2} in {vector3, vector3} do
      Vector.dot_product(v1, v2) ==
      (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z)
    end
  end

  property :dot_product_is_commutative do
    for_all {v1, v2} in {vector3, vector3} do
      Vector.dot_product(v1, v2) == Vector.dot_product(v2, v1)
    end
  end

  property :dot_product_is_distibutive do
    for_all {v1, v2, v3} in {vector3, vector3, vector3} do
      product_one = Vector.dot_product(v1, Vector.add(v2, v3))
      product_two = Vector.dot_product(v1, v2) + Vector.dot_product(v1, v3)
      Float.round(product_one, 5) == Float.round(product_two, 5)
    end
  end

  property :vector_projection do
    for_all {v1, v2} in {vector3, vector3} do
      dot_product = Vector.dot_product(v1, v2)
      x = (dot_product / Vector.magnitude_squared(v2)) * v2.x
      y = (dot_product / Vector.magnitude_squared(v2)) * v2.y
      z = (dot_product / Vector.magnitude_squared(v2)) * v2.z
      Vector.projection(v1, v2) == %Vector3{x: x, y: y, z: z}
    end
  end

  property :vector_cross_product do
    for_all {v1, v2} in {vector3, vector3} do
      dot_product = Vector.dot_product(v1, v2)
      x = -v1.z * v2.y + v1.y * v2.z
      y = v1.z * v2.x - v1.x * v2.z
      z = -v1.y * v2.x + v1.x * v2.y
      Vector3.cross_product(v1, v2) == %Vector3{x: x, y: y, z: z}
    end
  end

  property :cross_product_is_anticommutative do
    # a × b = -(b × a)
    for_all {v1, v2} in {vector3, vector3} do
      Vector3.cross_product(v1, v2) ==
        Vector.scalar_mult(Vector3.cross_product(v2, v1), -1)
    end
  end
end
