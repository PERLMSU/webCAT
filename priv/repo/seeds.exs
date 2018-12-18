alias Ecto.Multi
alias Ecto.Changeset
alias WebCAT.Repo
alias WebCAT.Accounts.User
alias WebCAT.Rotations.Classroom

admin_changeset =
  User.create_changeset(%User{}, %{
    first_name: "Admin",
    last_name: "Account",
    email: "wcat_admin@msu.edu",
    username: "admin",
    password: "password",
    bio: "The default administrative account.",
    city: "East Lansing",
    state: "MI",
    country: "USA",
    active: true,
    role: "admin"
  })

  classroom_changeset = Classroom.changeset(%Classroom{}, %{
    course_code: "PHY 183",
    title: "Physics for Scientists and Engineers I",
    description: "Default Classroom"
  })

transaction =
  Multi.new()
  |> Multi.insert(:admin, admin_changeset)
  |> Multi.run(:classroom, fn _repo, %{admin: admin} ->
    classroom_changeset
    |> Changeset.put_assoc(:users, [admin])
    |> Repo.insert()
  end)


{:ok, _} = Repo.transaction(transaction)
