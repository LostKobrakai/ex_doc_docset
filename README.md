# ExDocDocset

Bundles `ExDoc` documentation into a docset.

Docsets can be loaded into [Dash](https://kapeli.com/dash)(Mac OS) or
[Zeal](https://zealdocs.org/)(Win/Linux). Not yet tested with Zeal though.

## Usage

In `mix.exs` add the formatters config:

```elixir
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
```

The formatter will then create a docset in your `./doc` folder.

## TODO 

- [ ] More automated tests
- [ ] Correct types in table of contents (mark macros correctly)
- [ ] Handle extra files
- [ ] Check all types
  - [ ] Index
    - [x] Module
    - [x] Type
    - [x] Function
    - [x] Macro
    - [x] Protocol
    - [x] Callback
    - [x] Exception
    - [ ] Guide
    - [ ] Section
  - [ ] table of contents
    - [x] Type
    - [x] Function
    - [ ] Macro
    - [ ] Callback
    - [ ] Section
- [ ] Check in with the `ex_doc` team on how to make enough things public for the usecase:  
https://github.com/elixir-lang/ex_doc/issues/1548

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_doc_docset` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_doc_docset, github: "LostKobrakai/ex_doc_docset"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_doc_docset>.

