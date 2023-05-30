defmodule Mogrify.Mixfile do
  use Mix.Project

  @source_url "https://github.com/elixir-mogrify/mogrify"
  @version "0.9.3"

  def project do
    [
      app: :mogrify,
      version: @version,
      elixir: ">= 1.2.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:crypto, :logger]]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev, runtime: false}]
  end

  defp package do
    [
      description: "ImageMagick command line wrapper.",
      files: ["lib", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["Dmitry Vorotilin", "Andrew Shu"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/mogrify/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "LICENSE.md", "README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
