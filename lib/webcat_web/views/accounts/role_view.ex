defmodule WebCATWeb.RoleView do
  use WebCATWeb, :view

  alias Terminator.Role

  def render("list.json", %{roles: roles}) do
    render_many(roles, __MODULE__, "role.json")
  end

  def render("show.json", %{role: role}) do
    render_one(role, __MODULE__, "role.json")
  end

  def render("role.json", %{role: %Role{} = role}) do
    role
    |> Map.from_struct()
    |> Map.drop(~w(__meta__ performers)a)
    |> timestamps_format()
  end
end
