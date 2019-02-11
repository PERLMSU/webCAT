alias Ecto.Multi
alias Ecto.Changeset
alias WebCAT.Repo
alias WebCAT.Accounts.{User, PasswordCredentials}
alias WebCAT.Rotations.Classroom

@admin_email "wcat_admin@msu.edu"
@admin_password "password"

admin_changeset =
  User.changeset(%User{}, %{
    first_name: "Admin",
    last_name: "Account",
    email: "wcat_admin@msu.edu",
    active: true
  })

admin_group_changeset = Group.changeset(%Group{}, %{name: "admin"})
assistant_group_changeset = Group.changeset(%Group{}, %{name: "assistant"})

transaction =
  Multi.new()
  |> Multi.insert(:admin_group, admin_group_changeset)
  |> Multi.insert(:assistant_group, assistant_group_changeset)
  |> Multi.run(:admin, fn _repo, %{admin_group: group} ->
    admin_changeset
    |> Changeset.put_assoc(:groups, [group])
    |> Repo.insert()
  end)
  |> Multi.run(:admin_credentials, fn _repo, %{admin: user} ->
    %PasswordCredential{}
    |> PasswordCredential.changeset(%{
      email: @admin_email,
      password: @admin_password,
      user_id: user.id
    })
    |> Repo.insert()
  end)

{:ok, _} = Repo.transaction(transaction)
