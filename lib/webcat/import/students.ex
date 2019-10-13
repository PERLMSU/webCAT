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
         {:process, {:ok, students} } <- {:process, process_rows(section_id, Xlsxir.get_list(table_id))} do
      {:ok, students}
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
        %User{}
        |> User.changeset(Map.put(student, "role", "student"))
        |> put_assoc(:sections, [repo.get_by(Section, id: section_id)])
        |> repo.insert()
      end)
    end)

    case Repo.transaction(import_transaction) do
      {:ok, students} -> {:ok, Map.values(students)}
      {:error, _} -> :error
    end
  end
end
