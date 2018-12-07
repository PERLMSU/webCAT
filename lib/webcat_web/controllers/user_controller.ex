defmodule WebCATWeb.UserController do
  use WebCATWeb.Macros.Controller,
  schema: WebCAT.Accounts.User,
  item_name: "User",
  collection_name: "Users"
end
