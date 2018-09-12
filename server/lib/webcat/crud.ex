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
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> Repo.all()
  end

  @doc """
  Get by id
  """
  def get(schema, id) do
    acase Repo.get(schema, id) do
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
  def update(schema, id, update) do
    with {:ok, it} <- get(schema, id) do
      apply(schema, :changeset, [it, update])
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
