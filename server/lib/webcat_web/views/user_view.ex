defmodule WebCATWeb.UserView do
  @moduledoc """
  Render users
  """

  use WebCATWeb, :view

  alias WebCAT.Accounts.User

  def render("list.json", %{users: users}) do
    render_many(users, __MODULE__, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, __MODULE__, "user.json")
  end

  def render("user.json", %{user: %User{} = user}) do
    user
    |> Map.from_struct()
    |> Map.take(
      ~w(id first_name last_name middle_name email username nickname bio phone city state country birthday active role inserted_at updated_at)a
    )
  end
end
