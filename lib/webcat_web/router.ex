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

  pipeline :api do
    plug(:accepts, ["json"])
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

  scope "/api", WebCATWeb.API do
    pipe_through(~w(api authenticated)a)

    get("/feedback/:group_id/:student_id/:feedback_id", FeedbackController, :show)
    put("/feedback/:group_id/:student_id/:feedback_id", FeedbackController, :update)
    patch("/feedback/:group_id/:student_id/:feedback_id", FeedbackController, :update)
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
    get("/groups/:group_id/students/:user_id/categories", StudentFeedbackController, :categories)

    get(
      "/groups/:group_id/students/:user_id/categories/:category_id/observations",
      StudentFeedbackController,
      :observations
    )

    post("/groups/:group_id/students/:user_id/feedback", StudentFeedbackController, :feedback)
  end

  scope "/inbox", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    resources("/", InboxController)
    resources("/draft_id/comments", InboxController, except: ~w(index show edit new)a, name: "comments")
  end

  scope "/dashboard", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :index)
    get("/changes", IndexController, :changes)
    get("/import", IndexController, :import)
    post("/import", IndexController, :do_import)

    resources("/users", UserController)
    get("/users/:id/confirmation", UserController, :send_confirmation)

    resources("/students", StudentController)

    resources("/classrooms", ClassroomController)
    resources("/semesters", SemesterController)
    resources("/sections", SectionController)
    resources("/rotations", RotationController)
    resources("/rotation_groups", RotationGroupController)

    resources("/categories", CategoryController)
    resources("/observations", ObservationController)
    resources("/feedback", FeedbackController)
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
