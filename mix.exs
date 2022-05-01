defmodule ExDocDocset.MixProject do
  use Mix.Project

  @github "https://github.com/LostKobrakai/ex_doc_docset"

  def project do
    [
      app: :ex_doc_docset,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExDoc Docset",
      source_url: @github,
      homepage_url: @github,
      description: description(),
      package: package(),
      docs: [
        extras: ["README.md", "LICENSE.md"],
        formatters: ["html", "epub", ExDocDocset.Formatter.DocSet]
      ]
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
      {:ex_doc, "~> 0.27"},
      {:floki, ">= 0.30.0"},
      {:jason, "~> 1.0"},
      {:exqlite, "~> 0.10.0"},
      {:html5ever, "~> 0.12.0"}
    ]
  end

  defp description() do
    "A few sentences (a paragraph) describing the project."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github}
    ]
  end
end
