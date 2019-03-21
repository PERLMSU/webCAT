alias Ecto.Multi
alias WebCAT.Repo
alias WebCAT.Accounts.{User, PasswordCredential}

alias Terminator.{Ability, Performer, Role}

admin_changeset =
  User.changeset(%User{}, %{
    first_name: "Admin",
    last_name: "Account",
    email: "wcat_admin@msu.edu",
    active: true
  })

admin_password = "password"

transaction =
  Multi.new()
  |> Multi.insert(:admin, admin_changeset)
  |> Multi.run(:admin_credentials, fn _repo, %{admin: user} ->
    %PasswordCredential{}
    |> PasswordCredential.changeset(%{
      password: admin_password,
      user_id: user.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:granted, fn repo, transaction ->
    Performer.grant(transaction.admin.performer, repo.get_by(Role, identifier: "admin"))

    {:ok, nil}
  end)

{:ok, _} = Repo.transaction(transaction)

IO.puts("""
*****************************
* Email: wcat_admin@msu.edu *
* Password: #{admin_password}        *
*****************************
""")
