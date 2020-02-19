defmodule Peptide.Mixfile do
  use Mix.Project

  def project do
    [
      app: :peptide,
      version: "1.1.1",
      elixir: "~> 1.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [applications: [:httpoison, :logger]]
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.10", only: :dev},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.1"}
    ]
  end

  def package do
    %{
      description: "Environment loader, primarily for Phoenix",
      licenses: ["MIT"],
      maintainers: ["Alex Jones"],
      links: %{github: "https://github.com/thejones/peptide"}
    }
  end
end
