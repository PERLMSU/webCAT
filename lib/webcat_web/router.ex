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

  scope "/dashboard", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", DashboardController, :index)
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :index)
  end
end
