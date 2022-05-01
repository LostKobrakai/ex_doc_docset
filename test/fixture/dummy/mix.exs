defmodule Dummy.MixProject do
  use Mix.Project

  def project do
    [
      app: :dummy,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        formatters: [ExDocDocset.Formatter.DocSet]
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
      {:ex_doc_docset, path: "../../../"}
    ]
  end
end
