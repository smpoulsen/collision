defmodule Collision.Mixfile do
  use Mix.Project

  def project do
    [app: :collision,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.3.10", only: [:dev, :test]},
      {:dialyxir, "~> 0.3.3", only: [:dev, :test]},
      {:excheck, "~> 0.4.1", only: :test},
      {:triq, github: "krestenkrab/triq", only: :test},
    ]
  end

  defp description do
    """
    Vector operations and collision detection.
    """
  end

  defp package do
    [
      licenses: ["BSD2"],
      maintainers: ["Travis Poulsen"],
      links: %{"Github" => "https://github.com/tpoulsen/collision"}
    ]
  end
end
