defmodule WebCAT.Router do
  use WebCAT.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WebCAT do
    pipe_through :api
  end
end
