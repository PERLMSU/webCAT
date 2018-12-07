defmodule WebCATWeb.UserView do
  use WebCATWeb.Macros.Dashboard,
    schema: WebCAT.Accounts.User,
    item_name: "User",
    collection_name: "Users"
end
