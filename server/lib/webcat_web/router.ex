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

    get("/confirmations/:token", ConfirmationController, :show)
    patch("/confirmations/:token", ConfirmationController, :update)

    get("/resets/:token", ResetController, :show)
    patch("/resets/:token", ResetController, :update)

    resources("/me", ProfileController, only: ~w(show update)a)
    get("/me/notifications", ProfileController, :notifications)
    get("/me/classrooms", ProfileController, :classrooms)
    get("/me/rotation_groups", ProfileController, :rotation_groups)
  end
end
