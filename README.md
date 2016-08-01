# Collision
[![Build Status](https://travis-ci.org/tpoulsen/collision.svg?branch=master)](https://travis-ci.org/tpoulsen/collision)

Vector operations and collision detection for polygons.

Implements the [separating axis theorem](https://en.wikipedia.org/wiki/Hyperplane_separation_theorem) for collision detection for polygons in 2D space.

Using regular polygons with an arbitrary number of sides and of an artbitrary size, can detect collisions and calculate the minimum translation vector to resolve collision.

[Documentation](https://hexdocs.pm/collision/)

### Under development.
**TODO:**

+ Additional collision detection methods.
+ 3D collision detection


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `collision` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:collision, "~> 0.1.0"}]
    end
    ```

  2. Ensure `collision` is started before your application:

    ```elixir
    def application do
      [applications: [:collision]]
    end
    ```

