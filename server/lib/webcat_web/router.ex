defmodule WebCATWeb.Router do
  use WebCATWeb, :router
  use Plug.ErrorHandler

  pipeline :api do
    plug(:accepts, ["json"])
    plug(ProperCase.Plug.SnakeCaseParams)
  end

  scope "/auth", WebCATWeb do
    pipe_through(:api)

    post("/login", AuthController, :login)
    post("/signup", AuthController, :signup)
  end

  scope "/users", WebCATWeb do
    pipe_through(:api)

    resources("/", UserController, only: ~w(index show update)a)
    get("/:id/notifications", UserController, :notifications)
    get("/:id/classrooms", UserController, :classrooms)
    get("/:id/rotation_groups", UserController, :rotation_groups)
  end
end
