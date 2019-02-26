alias Ecto.Multi
alias WebCAT.Repo
alias Terminator.{Ability, Role}

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

with_abilities =
  (crud_abilities ++ other_abilities)
  |> Enum.reduce(Multi.new(), fn ability, multi ->
    Multi.run(multi, {:ability, ability.changes.identifier}, fn repo, _transaction ->
      case repo.get_by(Ability, identifier: ability.changes.identifier) do
        nil ->
          repo.insert(ability)

        found ->
          IO.puts("*** Abilities already created, skipping ***")
          {:ok, nil}
      end
    end)
  end)

with_roles =
  roles
  |> Enum.reduce(with_abilities, fn role, multi ->
    Multi.run(multi, {:role, role.changes.identifier}, fn repo, _transaction ->
      case repo.get_by(Role, identifier: role.changes.identifier) do
        nil ->
          repo.insert(role)

        found ->
          IO.puts("*** Roles already created, skipping ***")
          {:ok, nil}
      end
    end)
  end)

with_granted_abilities =
  Multi.run(with_roles, :granted, fn _repo, transaction ->
    with %Role{} = assistant_role <- Map.get(transaction, {:role, "assistant"}),
         %Role{} = student_role <- Map.get(transaction, {:role, "student"}) do
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

      {:ok, nil}
    else
      _ ->
        IO.puts("*** Roles already granted, skipping ***")
        {:ok, nil}
    end
  end)

{:ok, _} = Repo.transaction(with_granted_abilities)
