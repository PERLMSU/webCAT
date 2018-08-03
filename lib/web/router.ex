defmodule WebCAT.Router do
  use WebCAT.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", WebCAT do
    pipe_through(:api)
  end

  scope "/", WebCAT do
    get("/*path", PageController, :index)
  end
end
