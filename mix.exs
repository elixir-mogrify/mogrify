defmodule Mogrify.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mogrify,
      version: "0.2.0",
      elixir: ">= 1.0.0",
      description: description,
      package: package,
      deps: []
     ]
  end

  def application do
    [applications: [:crypto, :logger]]
  end

  defp description do
    "ImageMagick command line wrapper."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Dmitry Vorotilin"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/route/mogrify"}
    ]
  end
end
