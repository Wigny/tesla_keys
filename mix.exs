defmodule TeslaCase.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesla_case,
      version: "0.1.1",
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
      {:recase, "~> 0.7.0"},
      {:ex_doc, "~> 0.27.3", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Tesla middleware for converting the body keys of the request and response"
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/wigny/tesla_case"}
    ]
  end
end
