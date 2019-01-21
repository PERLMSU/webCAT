defmodule WebCATWeb.Router do
  use WebCATWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :not_authenticated do
    plug(WebCATWeb.Auth.Pipeline)
    plug(Guardian.Plug.EnsureNotAuthenticated)
  end

  pipeline :authenticated do
    plug(WebCATWeb.Auth.Pipeline)
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(Guardian.Plug.LoadResource)
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

  scope "/inbox", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    resources("/", InboxController)
  end

  scope "/dashboard", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :index)

    importable_resources("/users", UserController)

    importable_resources("/students", StudentController)

    importable_resources("/classrooms", ClassroomController)
    importable_resources("/classrooms/:classroom_id/semesters", SemesterController)
    importable_resources("/semesters/:semester_id/sections", SectionController)
    importable_resources("/sections/:section_id/rotations", RotationController)
    importable_resources("/rotations/:rotation_id/rotation_groups", RotationGroupController)

    importable_resources("/classrooms/:classroom_id/criteria", CriteriaController)

    importable_resources("/classrooms/:classroom_id/categories", CategoryController)
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :redirect_index)
    get("/logout", LoginController, :logout)
  end
end
