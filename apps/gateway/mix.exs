defmodule Gateway.Mixfile do
  use Mix.Project

  def project do
    [app: :gateway,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :porcelain], mod: {Gateway, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:porcelain, "~> 1.0"},
      {:erlsom, git: "https://github.com/willemdj/erlsom"},
      {:hexate,  ">= 0.5.0"},
      {:poison, ">= 1.4.0"}
    ]
  end
end
