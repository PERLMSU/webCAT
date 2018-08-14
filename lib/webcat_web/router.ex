defmodule WebCATWeb.Router do
  use WebCATWeb, :router
  use Plug.ErrorHandler

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(ProperCase.Plug.SnakeCaseParams)
  end

  pipeline :secure do
    plug(WebCATWeb.Auth.Pipeline)
  end

  scope "/auth", WebCATWeb do
    pipe_through(:api)

    post("/login", AuthController, :login)
    post("/signup", AuthController, :signup)
  end

  scope "/users", WebCATWeb do
    pipe_through(~w(api secure)a)

    resources("/", UserController, only: ~w(index show update)a)
    get("/:id/notifications", UserController, :notifications)
    get("/:id/classrooms", UserController, :classrooms)
    get("/:id/rotation_groups", UserController, :rotation_groups)
  end

  scope "/", WebCATWeb do
    pipe_through(:browser)
    get("/*path", PageController, :index)
  end
end
