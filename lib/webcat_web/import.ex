defmodule WebCATWeb.Import do
  alias Ecto.Multi
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup, Student}
  alias WebCAT.Feedback.{Category, Observation, Feedback}
  alias WebCAT.Accounts.User

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
            Multi.run(multi, {:classroom, classroom["id"]}, fn _repo, _transaction ->
              %Classroom{}
              |> Classroom.changeset(classroom)
              |> Repo.insert()
            end)
          end)

        semesters =
          Enum.reduce(Map.get(table_map, "semesters", []), classrooms, fn semester, multi ->
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
          end)

        sections =
          Enum.reduce(Map.get(table_map, "sections", []), semesters, fn section, multi ->
            Multi.run(multi, {:section, section["id"]}, fn _repo, transaction ->
              semester_id =
                transaction
                |> Map.get({:semester, section["semester_id"]}, %{})
                |> Map.get(:id, nil)

              %Section{}
              |> Section.changeset(Map.put(section, "semester_id", semester_id))
              |> Repo.insert()
            end)
          end)

        rotations =
          Enum.reduce(Map.get(table_map, "rotations", []), sections, fn rotation, multi ->
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
          end)

        rotation_groups =
          Enum.reduce(Map.get(table_map, "rotation_groups", []), rotations, fn rotation_group,
                                                                               multi ->
            Multi.run(multi, {:rotation_group, rotation_group["id"]}, fn _repo, transaction ->
              rotation_id =
                transaction
                |> Map.get({:rotation, rotation_group["rotation_id"]}, %{})
                |> Map.get(:id, nil)

              %RotationGroup{}
              |> RotationGroup.changeset(Map.put(rotation_group, "rotation_id", rotation_id))
              |> Repo.insert()
            end)
          end)

        students =
          Enum.reduce(Map.get(table_map, "students", []), rotation_groups, fn student, multi ->
            Multi.run(multi, {:student, student["id"]}, fn _repo, _transaction ->
              {:ok, user} =
                %User{}
                |> User.changeset(student)
                |> Repo.insert()

              %Student{}
              |> Student.changeset(Map.put(student, "user_id", user.id))
              |> Repo.insert()
            end)
          end)

        categories =
          Enum.reduce(Map.get(table_map, "categories", []), students, fn category, multi ->
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
          end)

        observations =
          Enum.reduce(Map.get(table_map, "observations", []), categories, fn observation, multi ->
            Multi.run(multi, {:observation, observation["id"]}, fn _repo, transaction ->
              category_id =
                transaction
                |> Map.get({:category, observation["category_id"]}, %{})
                |> Map.get(:id, nil)

              %Observation{}
              |> Observation.changeset(Map.put(observation, "category_id", category_id))
              |> Repo.insert()
            end)
          end)

        import_transaction =
          Enum.reduce(Map.get(table_map, "feedback", []), observations, fn feedback, multi ->
            Multi.run(multi, {:feedback, feedback["id"]}, fn _repo, transaction ->
              observation_id =
                transaction
                |> Map.get({:observation, feedback["observation_id"]}, %{})
                |> Map.get(:id, nil)

              %Feedback{}
              |> Feedback.changeset(Map.put(feedback, "observation_id", observation_id))
              |> Repo.insert()
            end)
          end)

        IO.inspect(Multi.to_list(import_transaction))

        {:ok, _} = Repo.transaction(import_transaction)

        :ok
    end
  end

  defp to_maps([]), do: []

  defp to_maps(list) do
    [header | rows] = list

    Enum.map(rows, fn row ->
      Enum.reduce(Enum.with_index(row), %{}, fn {elem, index}, map ->
        Map.put(map, Enum.at(header, index), case elem do
          {_, _, _} -> Date.from_erl!(elem)
          _ -> to_string(elem)
        end)
      end)
    end)
  end
end
