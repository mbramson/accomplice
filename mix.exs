defmodule Accomplice.Mixfile do
  use Mix.Project

  def project do
    [
      app: :accomplice,
      version: "0.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Accomplice",
      source_url: "https://github.com/mbramson/accomplice"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev},
      {:order_invariant_compare, "~> 1.0", only: :test},
      {:quixir, "~> 0.9", only: :test}
    ]
  end

  defp description() do
    """
    Accomplice is a library for grouping members of a list with a respect to a
    number of constraints.
    """
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Mathew Bramson"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mbramson/accomplice"}
    ]
  end
end
