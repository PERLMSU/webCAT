defmodule WebCAT.Rotations.Rotations do
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Rotations.Rotation

  def list(section_id) do
    from(rotation in Rotation,
      where: rotation.section_id == ^section_id,
      left_join: section in assoc(rotation, :section),
      left_join: semester in assoc(section, :semester),
      left_join: classroom in assoc(semester, :classroom),
      left_join: rotation_groups in assoc(rotation, :rotation_groups),
      left_join: rotation_group_rotation in assoc(rotation_groups, :rotation),
      preload: [
        rotation_groups: {rotation_groups, rotation: rotation_group_rotation},
        section: {section, semester: {semester, classroom: classroom}}
      ]
    )
    |> Repo.all()
  end

  def get(id) do
    from(rotation in Rotation,
      where: rotation.id == ^id,
      left_join: section in assoc(rotation, :section),
      left_join: semester in assoc(section, :semester),
      left_join: classroom in assoc(semester, :classroom),
      left_join: rotation_groups in assoc(rotation, :rotation_groups),
      left_join: rotation_group_rotation in assoc(rotation_groups, :rotation),
      left_join: users in assoc(classroom, :users),
      left_join: performer in assoc(users, :performer),
      left_join: roles in assoc(performer, :roles),
      preload: [
        rotation_groups: {rotation_groups, rotation: rotation_group_rotation},
        section: {section, semester: {semester, classroom: classroom}}
      ]
    )
    |> Repo.one()
    |> case do
      %Rotation{} = rotation -> {:ok, rotation}
      nil -> {:error, :not_found}
    end
  end
end
