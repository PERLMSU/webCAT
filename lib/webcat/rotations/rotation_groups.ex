defmodule WebCAT.Rotations.RotationGroups do
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Rotations.RotationGroup

  def list(rotation_id) do
    from(group in RotationGroup,
      where: group.rotation_id == ^rotation_id,
      left_join: rotation in assoc(group, :rotation),
      left_join: section in assoc(rotation, :section),
      left_join: semester in assoc(section, :semester),
      left_join: classroom in assoc(semester, :classroom),
      left_join: users in assoc(group, :users),
      preload: [
        users: users,
        rotation: {rotation, section: {section, semester: {semester, classroom: classroom}}}
      ]
    )
    |> Repo.all()
  end

  def get(id) do
    from(group in RotationGroup,
      where: group.id == ^id,
      left_join: rotation in assoc(group, :rotation),
      left_join: section in assoc(rotation, :section),
      left_join: semester in assoc(section, :semester),
      left_join: classroom in assoc(semester, :classroom),
      left_join: users in assoc(group, :users),
      preload: [
        users: users,
        rotation: {rotation, section: {section, semester: {semester, classroom: classroom}}}
      ]
    )
    |> Repo.one()
    |> case do
      %RotationGroup{} = group -> {:ok, group}
      nil -> {:error, :not_found}
    end
  end
end
