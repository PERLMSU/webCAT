defmodule WebCATWeb.Import do
  alias Ecto.Multi
  alias WebCAT.Repo
  alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup}
  alias WebCAT.Feedback.{Category, Observation, Feedback}
  alias WebCAT.Accounts.User
  alias Terminator.{Performer, Role}

  def from_path(path) do
    case Xlsxir.multi_extract(path) do
      {:error, _} = err ->
        err

      sheets ->
        table_map =
          Enum.reduce(sheets, %{}, fn {:ok, table}, map ->
            Map.put(map, Xlsxir.get_info(table, :name), to_maps(Xlsxir.get_list(table)))
          end)

        classrooms =
          Enum.reduce(Map.get(table_map, "classrooms", []), Multi.new(), fn classroom, multi ->
            if Map.has_key?(classroom, "id") do
              Multi.run(multi, {:classroom, classroom["id"]}, fn _repo, _transaction ->
                %Classroom{}
                |> Classroom.changeset(classroom)
                |> Repo.insert()
              end)
            end
          end)

        semesters =
          Enum.reduce(Map.get(table_map, "semesters", []), classrooms, fn semester, multi ->
            if Map.has_key?(semester, "id") do
              Multi.run(multi, {:semester, semester["id"]}, fn _repo, transaction ->
                classroom_id =
                  transaction
                  |> Map.get({:classroom, semester["classroom_id"]}, %{})
                  |> Map.get(:id, nil)

                casted_semester =
                  semester
                  |> Map.put("classroom_id", classroom_id)

                %Semester{}
                |> Semester.changeset(casted_semester)
                |> Repo.insert()
              end)
            end
          end)

        sections =
          Enum.reduce(Map.get(table_map, "sections", []), semesters, fn section, multi ->
            if Map.has_key?(section, "id") do
              Multi.run(multi, {:section, section["id"]}, fn _repo, transaction ->
                semester_id =
                  transaction
                  |> Map.get({:semester, section["semester_id"]}, %{})
                  |> Map.get(:id, nil)

                %Section{}
                |> Section.changeset(Map.put(section, "semester_id", semester_id))
                |> Repo.insert()
              end)
            end
          end)

        rotations =
          Enum.reduce(Map.get(table_map, "rotations", []), sections, fn rotation, multi ->
            if Map.has_key?(rotation, "id") do
              Multi.run(multi, {:rotation, rotation["id"]}, fn _repo, transaction ->
                section_id =
                  transaction
                  |> Map.get({:section, rotation["section_id"]}, %{})
                  |> Map.get(:id, nil)

                casted_rotation =
                  rotation
                  |> Map.put("section_id", section_id)

                %Rotation{}
                |> Rotation.changeset(casted_rotation)
                |> Repo.insert()
              end)
            end
          end)

        rotation_groups =
          Enum.reduce(Map.get(table_map, "rotation_groups", []), rotations, fn rotation_group,
                                                                               multi ->
            if Map.has_key?(rotation_group, "id") do
              Multi.run(multi, {:rotation_group, rotation_group["id"]}, fn _repo, transaction ->
                rotation_id =
                  transaction
                  |> Map.get({:rotation, rotation_group["rotation_id"]}, %{})
                  |> Map.get(:id, nil)

                %RotationGroup{}
                |> RotationGroup.changeset(Map.put(rotation_group, "rotation_id", rotation_id))
                |> Repo.insert()
              end)
            end
          end)

        students =
          Enum.reduce(Map.get(table_map, "students", []), rotation_groups, fn student, multi ->
            if Map.has_key?(student, "id") do
              Multi.run(multi, {:student, student["id"]}, fn _repo, _transaction ->
                {:ok, user} =
                  %User{}
                  |> User.changeset(student)
                  |> Repo.insert()

                # Add to student group on creation
                role = Repo.get_by!(Role, identifier: "student")
                Performer.grant(user, role)

                {:ok, user}
              end)
            end
          end)

        categories =
          Enum.reduce(Map.get(table_map, "categories", []), students, fn category, multi ->
            if Map.has_key?(category, "id") do
              Multi.run(multi, {:category, category["id"]}, fn _repo, transaction ->
                classroom_id =
                  transaction
                  |> Map.get({:classroom, category["classroom_id"]}, %{})
                  |> Map.get(:id, nil)

                parent_category_id =
                  transaction
                  |> Map.get({:category, category["parent_category_id"]}, %{})
                  |> Map.get(:id, nil)

                fixed_category =
                  category
                  |> Map.put("classroom_id", classroom_id)
                  |> Map.put("parent_category_id", parent_category_id)

                %Category{}
                |> Category.changeset(fixed_category)
                |> Repo.insert()
              end)
            end
          end)

        observations =
          Enum.reduce(Map.get(table_map, "observations", []), categories, fn observation, multi ->
            if Map.has_key?(observation, "id") do
              Multi.run(multi, {:observation, observation["id"]}, fn _repo, transaction ->
                category_id =
                  transaction
                  |> Map.get({:category, observation["category_id"]}, %{})
                  |> Map.get(:id, nil)

                %Observation{}
                |> Observation.changeset(Map.put(observation, "category_id", category_id))
                |> Repo.insert()
              end)
            end
          end)

        import_transaction =
          Enum.reduce(Map.get(table_map, "feedback", []), observations, fn feedback, multi ->
            if Map.has_key?(feedback, "id") do
              Multi.run(multi, {:feedback, feedback["id"]}, fn _repo, transaction ->
                observation_id =
                  transaction
                  |> Map.get({:observation, feedback["observation_id"]}, %{})
                  |> Map.get(:id, nil)

                %Feedback{}
                |> Feedback.changeset(Map.put(feedback, "observation_id", observation_id))
                |> Repo.insert()
              end)
            end
          end)

        case Repo.transaction(import_transaction) do
          {:ok, data} ->
            {:ok, data}

          {:error, _, changeset, _} ->
            IO.inspect(changeset)

            errors =
              Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
                Enum.reduce(opts, msg, fn {key, value}, acc ->
                  String.replace(acc, "%{#{key}}", to_string(value))
                end)
              end)

            data_string =
              Map.keys(changeset.changes)
              |> Enum.map(fn key ->
                case changeset.changes[key] do
                  change when is_binary(change) ->
                    unless Enum.empty?(String.to_charlist(change)), do: "#{key} = #{change}"

                  change when is_list(change) ->
                    unless Enum.empty?(change), do: "#{key} = #{change}"

                  change ->
                    "#{key} = #{change}"
                end
              end)
              |> Enum.join(", ")

            err_string =
              Map.keys(errors)
              |> Enum.map(fn key -> ~s(#{key}: #{Enum.join(errors[key], "AND")}) end)
              |> Enum.join(",")

            error_msg =
              "Errors for #{List.last(Module.split(changeset.data.__struct__))} with data #{
                data_string
              } : #{err_string}"

            {:error, error_msg}
        end
    end
  end

  defp to_maps([]), do: []

  defp to_maps(list) do
    [header | rows] = list

    Enum.map(rows, fn row ->
      Enum.reduce(Enum.with_index(row), %{}, fn {elem, index}, map ->
        Map.put(
          map,
          Enum.at(header, index),
          case elem do
            {_, _, _} -> Date.from_erl!(elem)
            _ -> to_string(elem)
          end
        )
      end)
    end)
  end

  defmodule WebCAT.Import.Error do
    defstruct ~w(data errors)a
  end
end
