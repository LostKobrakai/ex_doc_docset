defmodule ExDocDocset.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_doc_docset,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExDoc Docset",
      source_url: "https://github.com/LostKobrakai/ex_doc_docset",
      homepage_url: "https://github.com/LostKobrakai/ex_doc_docset",
      docs: [
        extras: ["README.md"],
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
end
