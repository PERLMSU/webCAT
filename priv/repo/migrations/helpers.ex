defmodule WebCAT.Repo.Helpers do
  use Ecto.Migration

  @doc """
  Creates an enum with a given name and values
  """
  def enum(name, values) do
    values_sql =
      values
      |> Enum.map(&~s('#{&1}'))
      |> Enum.join(", ")

    up = "CREATE TYPE #{name} AS ENUM (#{values_sql});"
    down = "DROP TYPE IF EXISTS #{name}"
    execute(up, down)
  end

  @doc """
  Installs an extension with the given name
  """
  def extension(name) do
    execute("CREATE EXTENSION IF NOT EXISTS #{name};", "DROP EXTENSION IF EXISTS #{name};")
  end

  @doc """
  Adds a required (not null) field to the schema
  """
  def add_req(name, type, options \\ []) do
    add(name, type, Keyword.put(options, :null, false))
  end
end
