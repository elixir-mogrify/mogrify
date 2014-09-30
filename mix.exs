defmodule Mogrify.Mixfile do
  use Mix.Project

  def project do
    [app: :mogrify,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  def application do
    [applications: [:crypto, :logger]]
  end

  defp deps do
    []
  end
end
