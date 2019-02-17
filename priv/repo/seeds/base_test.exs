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

crud_abilities =
  ~w(classroom semester section rotation rotation_group draft comment)
  |> Enum.flat_map(fn collection ->
    [
      Ability.build("create_#{collection}", "Create a new #{collection}"),
      Ability.build("show_#{collection}", "View a #{collection}"),
      Ability.build("update_#{collection}", "Update a #{collection}"),
      Ability.build("delete_#{collection}", "Delete a #{collection}")
    ]
  end)

other_abilities = [
  Ability.build("send_email", "Send an email to a student"),
  Ability.build("view_email", "View an email sent to a student"),
  Ability.build("approve_draft", "Change the approval status of a draft"),
  Ability.build("import", "Import data into the system")
]

roles = [
  Role.build("admin", [], "System administrator"),
  Role.build("assistant", [], "Classroom assistant"),
  Role.build("student", [], "A student in a section")
]

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

with_abilities =
  (crud_abilities ++ other_abilities)
  |> Enum.reduce(transaction, &Multi.insert(&2, {:ability, &1.changes.identifier}, &1))

with_roles =
  Enum.reduce(roles, with_abilities, &Multi.insert(&2, {:role, &1.changes.identifier}, &1))

with_granted_roles =
  Multi.run(with_roles, :granted, fn _repo, transaction ->
    assistant_role = Map.get(transaction, {:role, "assistant"})
    student_role = Map.get(transaction, {:role, "student"})

    Role.grant(assistant_role, Map.get(transaction, {:ability, "show_classroom"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "show_semester"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "show_section"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "show_rotation"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "show_rotation_group"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "create_draft"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "show_draft"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "update_draft"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "delete_draft"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "create_comment"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "show_comment"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "update_comment"}))
    Role.grant(assistant_role, Map.get(transaction, {:ability, "delete_comment"}))

    Role.grant(student_role, Map.get(transaction, {:ability, "view_email"}))

    Performer.grant(transaction.admin.performer, Map.get(transaction, {:role, "admin"}))

    {:ok, nil}
  end)

{:ok, _} = Repo.transaction(with_granted_roles)

IO.puts("""
*****************************
* Email: wcat_admin@msu.edu *
* Password: #{admin_password}        *
*****************************
""")
