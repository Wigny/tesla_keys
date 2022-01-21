defmodule TeslaKeys.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesla_keys,
      version: "0.1.2",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.0"},
      {:recase, "~> 0.7"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Aggregate of useful middlewares to manipulate body keys"
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/wigny/tesla_keys"}
    ]
  end
end
