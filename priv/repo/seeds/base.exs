alias Ecto.Multi
alias WebCAT.Repo
alias WebCAT.Accounts.{User, PasswordCredential}

alias Terminator.{Performer, Role}

admin_changeset =
  User.changeset(%User{}, %{
    first_name: "Admin",
    last_name: "Account",
    email: "wcat_admin@msu.edu",
    active: true,
    role: "admin"
  })

admin_password =
  :crypto.strong_rand_bytes(4)
  |> Base.encode32()
  |> String.downcase()

{:ok, transaction} =
  Multi.new()
  |> Multi.run(:admin, fn repo, _transaction ->
    case repo.get_by(User, email: admin_changeset.changes.email) do
      nil -> repo.insert(admin_changeset)
      admin -> {:ok, admin}
    end
  end)
  |> Multi.run(:admin_credentials, fn repo, %{admin: user} ->
    case repo.get_by(PasswordCredential, user_id: user.id) do
      nil ->
        %PasswordCredential{}
        |> PasswordCredential.changeset(%{
          password: admin_password,
          user_id: user.id
        })
        |> repo.insert()

      _ ->
        {:ok, nil}
    end
  end)
  |> Repo.transaction()

if transaction.admin_credentials do
  IO.puts("""
  *****************************
  * Email: wcat_admin@msu.edu *
  * Password: #{admin_password}        *
  *****************************
  """)
else
  IO.puts("*** Admin credentials already exist, skipping ***")
end
