defmodule WebCAT.CRUD do
  @moduledoc """
  Helper functions for doing basic CRUD actions
  """
  use Anaphora

  alias WebCAT.Repo

  import Ecto.Query

  @doc """
  List all of the schema
  """
  def list(schema, options \\ []) do
    schema
    |> where(^Keyword.get(options, :where, []))
    |> preload(^Keyword.get(options, :preload, []))
    |> order_by(~w(updated_at inserted_at))
    |> Repo.all()
  end

  @doc """
  Get by id
  """
  def get(schema, id, options \\ []) do
    schema
    |> where([s], s.id == ^id)
    |> preload(^Keyword.get(options, :preload, []))
    |> Repo.one()
    |> acase do
      nil -> {:error, :not_found}
      _ -> {:ok, it}
    end
  end

  @doc """
  Create
  """
  def create(schema, params) do
    schema.__struct__
    |> schema.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Update
  """
  def update(schema, struct, update) when is_map(struct) do
    schema.changeset(struct, update)
    |> Repo.update()
  end

  def update(schema, id, update) do
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
end
