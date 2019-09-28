defmodule WebCATWeb.UserController do
  alias WebCATWeb.UserView
  alias WebCAT.Accounts.User

  use WebCATWeb.ResourceController,
    schema: User,
    view: UserView,
    type: "user",
    filter: ~w(active),
    sort: ~w(email first_name last_name middle_name nickname active inserted_at updated_at)
end
