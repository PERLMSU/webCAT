alias Ecto.Multi
alias WebCAT.Repo
alias Terminator.{Ability, Role}


roles = [
  Role.build("admin", [], "System administrator"),
  Role.build("faculty", [], "Classroom assistant"),
  Role.build("teaching_assistant", [], "Classroom assistant"),
  Role.build("learning_assistant", [], "Classroom assistant"),
  Role.build("student", [], "A student in a section")
]

with_roles =
  roles
  |> Enum.reduce(Multi.new(), fn role, multi ->
    Multi.run(multi, {:role, role.changes.identifier}, fn repo, _transaction ->
      case repo.get_by(Role, identifier: role.changes.identifier) do
        nil ->
          repo.insert(role)

        _found ->
          IO.puts("*** Roles already created, skipping ***")
          {:ok, nil}
      end
    end)
  end)

{:ok, _} = Repo.transaction(with_roles)
