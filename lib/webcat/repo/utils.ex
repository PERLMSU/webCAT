defmodule WebCAT.Repo.Utils do
  import Ecto.Query
  import Ecto.Changeset
  alias WebCAT.Repo

  def put_relation(changeset, name, schema, ids) do
    with %{valid?: true} <- changeset,
         true <- is_list(ids) do
      data =
        schema
        |> where([s], s.id in ^(Enum.filter(ids, &is_integer/1)))
        |> Repo.all()

      put_assoc(changeset, name, data)
    else
      _ ->
        changeset
    end
  end
end
