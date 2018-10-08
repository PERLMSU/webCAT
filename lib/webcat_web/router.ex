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

  pipeline :authenticated do
    plug(WebCATWeb.Auth.Pipeline)
  end

  scope "/login", WebCATWeb do
    pipe_through(:browser)

    get("/", LoginController, :index)
    post("/", LoginController, :login)
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :index)
    get("/dashboard", DashboardController, :index)
    get("/dashboard/import_export", DashboardController, :import_export)

    resources("/semesters", SemestersController)
    resources("/classrooms", ClassroomsController)
    resources("/rotations", RotationsController)
    resources("/rotation_groups", RotationGroupsController)

    resources("/categories", CategoriesController)

    resources("/users", UsersController)

    get("/logout", LoginController, :logout)
  end
end
