defmodule WebCAT.Rotations.Sections do
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Rotations.Section

  def list(semester_id) do
    from(section in Section,
      where: section.semester_id == ^semester_id,
      left_join: semester in assoc(section, :semester),
      left_join: classroom in assoc(semester, :classroom),
      left_join: rotations in assoc(section, :rotations),
      left_join: rotation_section in assoc(rotations, :section),
      left_join: users in assoc(section, :users),
      preload: [
        users: users,
        rotations: {rotations, section: rotation_section},
        semester: {semester, classroom: classroom}
      ]
    )
    |> Repo.all()
  end

  def get(id) do
    from(section in Section,
      where: section.id == ^id,
      left_join: semester in assoc(section, :semester),
      left_join: classroom in assoc(semester, :classroom),
      left_join: rotations in assoc(section, :rotations),
      left_join: rotation_section in assoc(rotations, :section),
      left_join: users in assoc(section, :users),
      preload: [
        users: users,
        rotations: {rotations, section: rotation_section},
        semester: {semester, classroom: classroom}
      ]
    )
    |> Repo.one()
    |> case do
      %Section{} = section -> {:ok, section}
      nil -> {:error, :not_found}
    end
  end
end
