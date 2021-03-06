defmodule Mpdex.MixProject do
  use Mix.Project

  def project do
    [
      app: :mpdex,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Mpdex.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, "~> 0.22", only: :dev, runtime: false}]
  end

  defp description do
    """
    Elixir client for Music Player Daemon.
    """
  end

  defp package do
    [
      maintainers: ["Boško Ivanišević"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bosko/mpdex"}
    ]
  end
end
