defmodule WebCAT.Import.Students do
  alias WebCAT.Repo
  alias Ecto.Multi
  alias WebCAT.Accounts.User
  import Ecto.Changeset
  alias Terminator.{Performer, Role}
  alias WebCAT.Rotations.Section


  def import(section_id, path) do
    # Extract the first sheet in the file
    with {:extract, {:ok, table_id}} <- {:extract, Xlsxir.multi_extract(path, 0)},
         {:process, :ok } <- {:process, process_rows(section_id, Xlsxir.get_list(table_id))} do
      :ok
    else
      {:extract, _} -> {:error, "Problem extracting data from the spreadsheet"}
      {:process, _} -> {:error, "Problem importing data."}
    end
  end

  defp process_rows(section_id, list) do
    [headers | rows] = list

    maps = Enum.map(rows, fn row ->
      Enum.reduce(Enum.with_index(row), %{}, fn {elem, index}, map ->
        Map.put(
          map,
          Enum.at(headers, index),
          case elem do
            {_, _, _} -> Date.from_erl!(elem)
            _ -> to_string(elem)
          end
        )
      end)
    end)

    import_transaction = Enum.reduce(maps, Multi.new(), fn student, multi ->
      Multi.run(multi, student["email"], fn repo, _transaction ->
        performer = repo.insert!(%Performer{})
        role = repo.get_by(Role, identifier: "student")
        Performer.grant(performer, role)

        %User{}
        |> User.changeset(student)
        |> put_assoc(:performer, performer)
        |> put_assoc(:sections, [repo.get_by(Section, id: section_id)])
        |> repo.insert()
      end)
    end)

    case Repo.transaction(import_transaction) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end
end
