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

    get("/credential", LoginController, :credential_login)

    get("/reset", PasswordResetController, :index)
    post("/reset", PasswordResetController, :create)
    get("/reset/:token", PasswordResetController, :reset)
    post("/reset/:token", PasswordResetController, :finish_reset)
  end

  scope "/student_feedback", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", StudentFeedbackController, :classrooms)
    get("/semesters/:semester_id/sections", StudentFeedbackController, :sections)
    get("/rotations/:rotation_id/rotation_groups", StudentFeedbackController, :groups)
    get("/groups/:group_id", StudentFeedbackController, :students)
    get("/groups/:group_id/students/:student_id/categories", StudentFeedbackController, :categories)
    get("/groups/:group_id/students/:student_id/categories/:category_id/observations", StudentFeedbackController, :observations)
  end

  scope "/inbox", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    resources("/", InboxController)
    resources("/draft_id/comments", InboxController, except: ~w(index show)a, name: "comments")
  end

  scope "/dashboard", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :index)
    get("/changes", IndexController, :changes)
    get("/import", IndexController, :import)
    post("/import", IndexController, :do_import)

    importable_resources("/users", UserController)

    importable_resources("/students", StudentController)

    importable_resources("/classrooms", ClassroomController)
    importable_resources("/classrooms/:classroom_id/semesters", SemesterController)
    importable_resources("/semesters/:semester_id/sections", SectionController)
    importable_resources("/sections/:section_id/rotations", RotationController)
    importable_resources("/rotations/:rotation_id/rotation_groups", RotationGroupController)

    importable_resources("/classrooms/:classroom_id/categories", CategoryController)
    importable_resources("/categories/:category_id/observations", ObservationController)
    importable_resources("/observations/:observation_id/feedback", FeedbackController)
  end

  scope "/profile", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    resources("/", ProfileController, only: ~w(show edit update)a, singleton: true)
    get("/password/edit", ProfileController, :edit_password)
    put("/password", ProfileController, :update_password)
    patch("/password", ProfileController, :update_password)
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :redirect_index)
    get("/logout", LoginController, :logout)
  end
end
