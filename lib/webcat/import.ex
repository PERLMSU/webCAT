defmodule WebCAT.Import do
  alias WebCAT.Rotations.Classroom
  alias WebCAT.Repo

  def import(:classrooms, path) do
    result =
      File.stream!(path, [:trim_bom, encoding: :utf8])
      |> CSV.decode(headers: true, strip_fields: true)
      |> Stream.map(fn element ->
        case element do
          {:ok, data} ->
            Classroom.changeset(%Classroom{}, data)
            |> Repo.insert()
            |> case do
              {:ok, _} ->
                :ok

              {:error, _} ->
                :error
            end

          {:error, _} ->
            :error
        end
      end)
      |> Enum.to_list()
      |> Enum.reduce(%{ok: 0, error: 0}, fn result, acc ->
        case result do
          :ok -> Map.update!(acc, :ok, &(&1 + 1))
          :error -> Map.update!(acc, :error, &(&1 + 1))
        end
      end)

    {:ok, result}
  end

  def import(op, _), do: {:error, "Unsupported import operation #{op}"}
end
