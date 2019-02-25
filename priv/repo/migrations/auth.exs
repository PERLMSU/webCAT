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
  |> Enum.reduce(Multi.new(), &Multi.insert(&2, {:ability, &1.changes.identifier}, &1))

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

    {:ok, nil}
  end)

{:ok, _} = Repo.transaction(with_granted_roles)
