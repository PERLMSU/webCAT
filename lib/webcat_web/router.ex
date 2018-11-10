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

    get("/reset", PasswordResetController, :index)
    post("/reset", PasswordResetController, :create)
    get("/reset/:token", PasswordResetController, :reset)
    post("/reset/:token", PasswordResetController, :finish_reset)

    get("/confirm/:token", EmailConfirmationController, :confirm)
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :index)
    get("/dashboard", DashboardController, :index)

    resources("/:resource", CRUDController)

    get("/logout", LoginController, :logout)
  end
end
