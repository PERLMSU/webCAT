defmodule WebCAT.Rotations.Classrooms do
  alias WebCAT.Repo
  alias WebCAT.Rotations.{Classroom, Rotation}
  import Ecto.Query

  def list() do
    from(classroom in Classroom,
      left_join: semesters in assoc(classroom, :semesters),
      left_join: users in assoc(classroom, :users),
      preload: [
        semesters: semesters,
        users: users
      ]
    )
    |> Repo.all()
  end

  def get(id) do
    from(classroom in Classroom,
      where: classroom.id == ^id,
      left_join: categories in assoc(classroom, :categories),
      left_join: parent_category in assoc(categories, :parent_category),
      left_join: sub_categories in assoc(categories, :sub_categories),
      left_join: semesters in assoc(classroom, :semesters),
      left_join: sections in assoc(semesters, :sections),
      left_join: users in assoc(classroom, :users),
      left_join: performer in assoc(users, :performer),
      left_join: roles in assoc(performer, :roles),
      preload: [
        semesters: {semesters, sections: sections},
        categories:
          {categories, sub_categories: sub_categories, parent_category: parent_category},
        users: {users, performer: {performer, roles: roles}}
      ]
    )
    |> Repo.one()
    |> case do
      %Classroom{} = classroom -> {:ok, classroom}
      nil -> {:error, :not_found}
    end
  end

  def get_active_rotation(%Classroom{id: classroom_id}) do
    date = Timex.now()

    from(rotation in Rotation,
      left_join: section in assoc(rotation, :section),
      left_join: semester in assoc(section, :semester),
      where: semester.classroom_id == ^classroom_id,
      where: rotation.start_date <= ^date,
      where: rotation.end_date >= ^date
    )
    |> Repo.one()
  end
end
