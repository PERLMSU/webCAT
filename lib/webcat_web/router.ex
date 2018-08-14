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
    plug(WebCATWeb.Auth.Pipeline)
  end

  scope "/auth", WebCATWeb do
    pipe_through(:api)

    post("/login", AuthController, :login)
    post("/signup", AuthController, :signup)
  end

  scope "/", WebCATWeb do
    pipe_through(:browser)
    get("/*path", PageController, :index)
  end
end
