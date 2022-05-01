defmodule ExDocDocset do
  @moduledoc """
  Bundles `:ex_doc` documentation into a docset.

  Docsets can be loaded into [Dash](https://kapeli.com/dash)(Mac OS) or
  [Zeal](https://zealdocs.org/)(Win/Linux).

  ## Usage

  In `mix.exs` add the formatters config:

      def project do
        [
          app: :my_app,
          version: "0.1.0-dev",
          deps: deps(),

          # Docs
          docs: [
            formatters: ["html", "epub", ExDocDocset.Formatter.DocSet]
          ]
        ]
      end

  The formatter will then create a docset in your `./doc` folder.

  """
end
