defmodule WebCAT.Rotations.Semesters do
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Rotations.Semester

  def list(classroom_id) do
    from(semester in Semester,
      where: semester.classroom_id == ^classroom_id,
      left_join: classroom in assoc(semester, :classroom),
      left_join: sections in assoc(semester, :sections),
      left_join: users in assoc(semester, :users),
      preload: [classroom: classroom, sections: sections, users: users]
    )
    |> Repo.all()
  end

  def list() do
    from(semester in Semester,
      left_join: classroom in assoc(semester, :classroom),
      left_join: sections in assoc(semester, :sections),
      left_join: users in assoc(semester, :users),
      preload: [classroom: classroom, sections: sections, users: users]
    )
    |> Repo.all()
  end

  def get(id) do
    from(semester in Semester,
      where: semester.id == ^id,
      left_join: classroom in assoc(semester, :classroom),
      left_join: sections in assoc(semester, :sections),
      left_join: users in assoc(semester, :users),
      preload: [classroom: classroom, sections: sections, users: users]
    )
    |> Repo.one()
    |> case do
      %Semester{} = semester -> {:ok, semester}
      nil -> {:error, :not_found}
    end
  end
end
