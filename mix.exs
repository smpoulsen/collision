defmodule Collision.Mixfile do
  use Mix.Project

  def project do
    [app: :collision,
     version: "0.3.1",
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

  defp deps do
    [
      {:credo, "~> 0.3.10", only: [:dev, :test]},
      {:dialyxir, "~> 0.3.3", only: [:dev, :test]},
      {:excheck, "~> 0.4.1", only: :test},
      {:triq, github: "krestenkrab/triq", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    A library for creating, manipulating, and detecting and resolving collisions between polygons.
    """
  end

  defp package do
    [
      licenses: ["BSD2"],
      maintainers: ["Sylvie Poulsen"],
      links: %{
        "Github" => "https://github.com/smpoulsen/collision",
        "Docs" => "https://hexdocs.pm/collision/"
      }
    ]
  end
end
