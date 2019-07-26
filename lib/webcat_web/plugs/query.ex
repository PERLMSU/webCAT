defmodule WebCATWeb.Plug.Query do
  @behaviour Plug
  alias Plug.Conn

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    query =
      conn
      |> Conn.fetch_query_params()
      |> Map.get(:query_params)
      |> Map.take(~w(sort filter fields include)a)
      |> parse_sort(Keyword.get(opts, :sort, []))
      |> parse_filter(Keyword.get(opts, :filter, []))
      |> parse_fields(Keyword.get(opts, :fields, []))
      |> parse_include(Keyword.get(opts, :include, []))

    Conn.assign(conn, :parsed_query, struct(__MODULE__.ParsedQuery, query))
  end

  defp parse_sort(query, []), do: query

  defp parse_sort(%{sort: sort} = query, sort_opts) when is_list(sort) do
    Map.update!(query, :sort, fn sort ->
      parsed = sort
      |> Enum.map(fn field ->
        [_, direction, field] = Regex.run(~r/(-?)(\S*)/, field)

        case direction do
          "-" -> [desc: field]
          _ -> [asc: field]
        end
      end)
      |> Enum.filter(fn {_dir, field} ->
        Enum.any?(sort_opts, fn opt -> opt == field or to_string(opt) == field end)
      end)
      |> Enum.map(fn {dir, field} -> {dir, String.to_atom(field)} end)

      # All schemas have timestamps, so all can be sorted by timestamps
      [:inserted_at | [:updated_at | parsed]]
    end)
  end

  defp parse_sort(query, _), do: query

  defp parse_filter(query, []), do: query

  defp parse_filter(%{filter: filter} = query, filter_opts) when is_map(filter) do
    Map.update!(query, :filter, fn filter ->
      filter
      |> Map.to_list()
      |> Enum.filter(fn {key, _val} ->
        Enum.any?(filter_opts, fn opt -> opt == key or to_string(opt) == key end)
      end)
      |> Enum.map(fn {key, val} -> {String.to_atom(key), val} end)
    end)
  end

  defp parse_filter(query, _), do: query

  defp parse_fields(query, []), do: query

  defp parse_fields(%{fields: fields} = query, field_opts) when is_list(fields) do
    Map.update!(query, :include, fn fields ->
      fields
      |> Enum.filter(fn field ->
        Enum.any?(field_opts, fn opt -> opt == field or to_string(opt) == field end)
      end)
      |> Enum.map(fn field -> String.to_atom(field) end)
    end)
  end

  defp parse_fields(query, field_opts), do: Map.put(query, :fields, field_opts)

  defp parse_include(query, []), do: query

  defp parse_include(%{include: include} = query, include_opts) when is_list(include) do
    Map.update!(query, :include, fn include ->
      include
      |> Enum.filter(fn field ->
        Enum.any?(include_opts, fn opt -> opt == field or to_string(opt) == field end)
      end)
      |> Enum.map(fn field -> String.to_atom(field) end)
    end)
  end

  defp parse_include(query, _), do: query

  defmodule ParsedQuery do
    defstruct sort: [], filter: [], fields: [], include: []
  end
end
