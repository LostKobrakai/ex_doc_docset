defmodule ExDocDocset.Formatter.DocSet do
  @moduledoc false
  alias ExDocDocset.Formatter.DocSet.Templates
  alias Exqlite.Basic

  # Typespec not public
  # @spec run(list, ExDoc.Config.t()) :: String.t()
  def run(list, config) do
    config = normalize_config(config)
    docset = Path.join([config.output, "#{config.project}.docset"])

    # Paths

    # Cleanup
    File.rm_rf!(docset)

    # Build HTML
    files_folder = Path.join([docset, "/Contents/Resources/Documents"])
    ExDoc.Formatter.HTML.run(list, %{config | output: files_folder})
    patch_css(files_folder)
    modify_html(files_folder)

    # Build Info.plist
    info_plist = Path.join(docset, "/Contents/Info.plist")
    File.write!(info_plist, Templates.info_plist(config.project))

    # Build Info.plist (seems to be needed for Zeal only)
    meta_json = Path.join(docset, "/meta.json")
    File.write!(meta_json, Templates.meta_json(config))

    # Build index
    index = Path.join(docset, "/Contents/Resources/docSet.dsidx")
    build_index(index, list)

    docset
  end

  # Config path not used for docsets
  defp normalize_config(config) do
    %{config | javascript_config_path: nil}
  end

  defp patch_css(files_folder) do
    [file] = Path.wildcard(Path.join(files_folder, "dist/elixir-*.css"))
    css = File.read!(file)
    css = Regex.replace(~r/(@media screen and \(max-width: ?)\d*?px\)/, css, "\\g{1}1px)")
    css = String.replace(css, ".night-mode", ".night-mode-disabled")
    File.write!(file, [css, Templates.overwrite_css()])
  end

  defp modify_html(files_folder) do
    for path <- Path.wildcard(Path.join(files_folder, "*.html")) do
      path
      |> File.read!()
      |> Floki.parse_document!()
      |> Floki.filter_out(".summary")
      |> Floki.traverse_and_update(fn
        {el, attrs, children} = node ->
          case Floki.attribute(node, "id") do
            ["types"] -> {el, attrs, tag_type(:tag, children)}
            ["callbacks"] -> {el, attrs, tag_type(:callback, children)}
            ["functions"] -> {el, attrs, tag_type(:function, children)}
            _ -> node
          end

        other ->
          other
      end)
      |> Floki.raw_html()
      |> then(&File.write!(path, &1))
    end
  end

  # Incorrectly tags macros as functions atm
  defp tag_type(type, doc) when type in [:tag, :callback, :function] do
    Floki.traverse_and_update(doc, fn
      {el, attrs, children} = node ->
        cond do
          "#{type}s-list" in Floki.attribute(node, "class") ->
            children =
              Enum.flat_map(children, fn
                {_node, _, _} = function ->
                  [id] = Floki.attribute(function, "id")
                  encoded_name = URI.encode_www_form(name_from_id(type, id))
                  name = "//apple_ref/cpp/#{docsetType(type)}/#{encoded_name}"
                  link = {"a", [{"name", name}, {"class", "dashAnchor"}], []}
                  [link, function]

                text ->
                  [text]
              end)

            {el, attrs, children}

          true ->
            node
        end

      other ->
        other
    end)
  end

  defp name_from_id(:tag, id) do
    <<"t:", name::binary>> = id
    name
  end

  defp name_from_id(:callback, id) do
    <<"c:", name::binary>> = id
    name
  end

  defp name_from_id(:function, id) do
    id
  end

  defp docsetType(:tag), do: "Type"
  defp docsetType(:callback), do: "Callback"
  defp docsetType(:function), do: "Function"

  defp build_index(db, list) do
    {:ok, conn} = Basic.open(db)

    {:ok, _, _, _} =
      Basic.exec(conn, """
      CREATE TABLE searchIndex(
        id INTEGER PRIMARY KEY,
        name TEXT,
        type TEXT,
        path TEXT
        );
      """)

    sql = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?1, ?2, ?3)"

    index_fn = fn name, type, path ->
      {:ok, _, _, _} = Basic.exec(conn, sql, [name, type, path])
    end

    for %ExDoc.ModuleNode{} = module <- list do
      type =
        case module.type do
          :module -> "Module"
          :protocol -> "Protocol"
          :behaviour -> "Module"
          :exception -> "Exception"
        end

      index_fn.(module.title, type, "#{module.id}.html#content")

      for %ExDoc.FunctionNode{type: :function} = fun <- module.docs do
        index_fn.("#{module.title}.#{fun.id}", "Function", "#{module.id}.html##{fun.id}")
      end

      for %ExDoc.FunctionNode{type: :macro} = macro <- module.docs do
        index_fn.("#{module.title}.#{macro.id}", "Macro", "#{module.id}.html##{macro.id}")
      end

      for %ExDoc.FunctionNode{type: :callback} = callback <- module.docs do
        <<"c:", name::binary>> = id = callback.id
        index_fn.("#{module.title}.#{name}", "Callback", "#{module.id}.html##{id}")
      end

      for %ExDoc.TypeNode{} = type <- module.typespecs do
        <<"t:", name::binary>> = id = type.id
        index_fn.("#{module.title}.#{name}", "Type", "#{module.id}.html##{id}")
      end
    end

    # close connection
    Basic.close(conn)
  end
end
