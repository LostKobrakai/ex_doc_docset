defmodule ExDocDocset.Formatter.DocSet.Templates do
  @moduledoc false
  require EEx

  def meta_json(config) do
    meta = %{
      extra: %{isJavaScriptEnabled: true},
      name: id(config),
      version: config.version,
      title: config.project
    }

    Jason.encode!(meta)
  end

  defp id(%{apps: [app]}), do: Atom.to_string(app)
  defp id(%{project: project}), do: project |> String.downcase()

  templates = [
    info_plist: [:name]
  ]

  Enum.each(templates, fn {name, args} ->
    filename = Path.expand("templates/#{name}.eex", __DIR__)
    @external_resource filename
    @doc false
    EEx.function_from_file(:def, name, filename, args, trim: true)
  end)
end
