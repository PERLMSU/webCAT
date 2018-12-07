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

  scope "/feedback", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", FeedbackController, :index)
    get("/:rotation_group_id", FeedbackController, :show_rotation_group)
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    resources("/categories", CategoryController)
    resources("/classrooms", ClassroomController)
    resources("/rotations", RotationController)
    resources("/rotation_groups", RotationGroupController)
    resources("/semesters", SemesterController)
    resources("/students", StudentController)
    resources("/users", UserController)

    get("/", IndexController, :index)

    get("/logout", LoginController, :logout)
  end
end
