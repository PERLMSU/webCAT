defmodule WebCATWeb.UsersView do
  use WebCATWeb, :view

  def clean_user(user) do
    user
    |> Map.from_struct()
    |> Map.take(~w(id first_name last_name username)a)
  end
end
