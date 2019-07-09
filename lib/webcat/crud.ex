defmodule WebCAT.CRUD do
  @moduledoc """
  Helper functions for doing basic CRUD actions
  """
  alias WebCAT.Repo
  import Ecto.Query

  @doc """
  List all of the schema
  """
  def list(schema, options \\ []) do
    schema
    |> where(^fetch_opt(options, :filter, []))
    |> preload(^fetch_opt(options, :include, []))
    |> order_by(^fetch_opt(options, :sort, []))
    |> select(^fetch_opt(options, :fields, schema.__schema__(:fields)))
    |> Repo.all()
  end

  @doc """
  Get by id
  """
  def get(schema, id, options \\ []) do
    schema
    |> where([s], s.id == ^id)
    |> preload(^fetch_opt(options, :include, []))
    |> select(^fetch_opt(options, :fields, schema.__schema__(:fields)))
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      _ = it -> {:ok, it}
    end
  end

  @doc """
  Create
  """
  def create(schema, params, options \\ []) do
    schema.__struct__
    |> schema.changeset(params)
    |> Repo.insert(on_conflict: Keyword.get(options, :on_conflict, :raise))
  end

  @doc """
  Update
  """
  def update(schema, struct, update) when is_map(struct) and is_map(update) do
    schema.changeset(struct, update)
    |> Repo.update()
  end

  def update(schema, id, update) when (is_binary(id) or is_integer(id)) and is_map(update) do
    with {:ok, it} <- get(schema, id) do
      schema.changeset(it, update)
      |> Repo.update()
    end
  end

  @doc """
  Delete
  """
  def delete(schema, id) do
    with {:ok, it} <- get(schema, id) do
      Repo.delete(it)
    end
  end

  defp fetch_opt(opt, key, default) do
    val = Keyword.get(opt, key, [])
    if val == [], do: default, else: val
  end
end
