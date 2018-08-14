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
    |> Map.drop(~w(password)a)
  end
end
